# terraform

The bxmesh.net zone's base config: MX to Google, its tunnel, Access apps; its own R2 state;
GitHub-hosted runners (O59, O60, O80, O128). The design, the layout and the rules are in
[`zindello-cluster/cluster-docs`](https://github.com/zindello-cluster/cluster-docs).

The names of BxMesh's sites aren't here: cluster-02's external-dns for bxmesh.net writes each one
from the app's own route (K23).

| File | What it is |
| --- | --- |
| `stacks/cloudflare/tunnel.tf` | BxMesh's own tunnel, remotely managed: `bxmesh.net` and `*.bxmesh.net` go to BxMesh's gateway in cluster-02, anything else gets a 404 (O59, O73, A23) |
| `stacks/cloudflare/access.tf` | Access, owner only by a one-time code, as on cluster-01: `bxmesh.net/admin`, the observers' approvals (O126), and `mqtt-admin.bxmesh.net`, the broker's dashboard (O123), taken over from cluster-01 |
| `stacks/cloudflare/email.tf` | bxmesh.net's MX to Google Workspace (O60) |
| `stacks/cloudflare/external-dns.tf` | The token for cluster-02's external-dns for bxmesh.net: Zone Read and DNS Write on bxmesh.net only (K23) |
| `stacks/cloudflare/outputs.tf` | The tunnel's ID and CNAME target, the Access audiences, and the two tokens (sensitive) |
| `stacks/cloudflare/tofu.sh` | OpenTofu from the owner's laptop, its state credentials from the keychain |
| `stacks/cloudflare/to-openbao.sh` | Moves the two tokens from the state straight into OpenBao, once |
| `.github/workflows/tofu.yml` | Plan on a pull request, apply on `main` (O80) |

## State

In its own R2 bucket in the owner's account, **`bxmesh-tofu-state`**, key `terraform.tfstate`,
encrypted by OpenTofu with a passphrase (O80). The bucket is made by hand before the first apply,
as cluster-02's was (O30); nothing here creates it.

## CI

On GitHub's own runners. Each pull request is checked (`fmt`, `validate`) and planned, and the plan
is commented on it. Each push to `main` applies.

| GitHub environment | Used by | Branches | Its Cloudflare token |
| --- | --- | --- | --- |
| `main` | the apply | `main` only | the apply token |
| `plan` | the pull request plan | this repo's own branches (forks get no secrets) | read-only |

Each has four secrets: `CLOUDFLARE_API_TOKEN`, `R2_ACCESS_KEY_ID`, `R2_SECRET_ACCESS_KEY` and
`STATE_PASSPHRASE`.

| Token | Permissions |
| --- | --- |
| Apply | Account: Cloudflare Tunnel Edit, Access: Apps and Policies Edit, Account API Tokens Edit. Zone bxmesh.net: Zone Read, DNS Edit |
| Plan | Account: Cloudflare Tunnel Read, Access: Apps and Policies Read, Account API Tokens Read. Zone bxmesh.net: Zone Read, DNS Read |
| R2, `main` | Object Read & Write, on `bxmesh-tofu-state` only |
| R2, `plan` | Object Read only, on `bxmesh-tofu-state` only (the plan takes no lock) |

## Before the first apply (yours, once)

1. **The bucket:** in the Cloudflare dashboard, R2, create `bxmesh-tofu-state`.
2. **The R2 keys:** R2, Manage API tokens: one Object Read & Write token and one Object Read only
   token, each for `bxmesh-tofu-state` only.
3. **The Cloudflare tokens:** Manage Account, Account API Tokens: the apply token and the plan
   token above.
4. **The passphrase:** choose one, at least 16 characters.
5. **The environments** (in this repo's settings, or with `gh`): `main`, limited to the `main`
   branch, and `plan`, with their secrets. `gh secret set` asks for each value without showing it:

   ```sh
   gh api -X PUT repos/bxmesh/terraform/environments/main \
     -F 'deployment_branch_policy[protected_branches]=false' \
     -F 'deployment_branch_policy[custom_branch_policies]=true'
   gh api -X POST repos/bxmesh/terraform/environments/main/deployment-branch-policies \
     -f name=main -f type=branch
   gh api -X PUT repos/bxmesh/terraform/environments/plan
   for env in main plan; do
     for s in CLOUDFLARE_API_TOKEN R2_ACCESS_KEY_ID R2_SECRET_ACCESS_KEY STATE_PASSPHRASE; do
       gh secret set "$s" --env "$env" --repo bxmesh/terraform
     done
   done
   ```

6. **Your keychain**, for `tofu.sh` (the read-and-write R2 pair and the passphrase). Each asks for
   the value and never shows it:

   ```sh
   security add-generic-password -a bxmesh -s bxmesh-tofu-state-r2-access-key-id -w
   security add-generic-password -a bxmesh -s bxmesh-tofu-state-r2-secret-access-key -w
   security add-generic-password -a bxmesh -s bxmesh-tofu-state-passphrase -w
   ```

## After the first apply

Move the two tokens into OpenBao, straight from the state, never printed (O57), with
cluster-terraform's `bao.sh` (it defaults to `~/repositories/zindello/cluster-terraform`):

```sh
cd stacks/cloudflare
./tofu.sh init
./to-openbao.sh [path to cluster-terraform/stacks/openbao/bao.sh]
```

| Output | Goes to |
| --- | --- |
| `tunnel_token` | `secret/dmz-bxmesh-cloudflared/tunnel`, key `token` (cloudflared, O80) |
| `external_dns_token` | `secret/platform-external-dns/bxmesh`, key `token` (external-dns, K23) |

The rest aren't secrets: `./tofu.sh output` (in `stacks/cloudflare`) shows them. `admin_access_aud` is the observers app's
`ACCESS_AUD` (its `ACCESS_TEAM` is `zindello.cloudflareaccess.com`), and `tunnel_cname` is the
target external-dns writes for bxmesh.net.
