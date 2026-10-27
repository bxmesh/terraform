# terraform

The bxmesh.net zone's base config: MX to Google, its tunnel, Access apps; its own R2 state;
applied from the owner's laptop, checked by CI (O59, O60, O80, O128, O169). The design, the layout and the rules are in
[`zindello-cluster/cluster-docs`](https://github.com/zindello-cluster/cluster-docs).

external-dns's own token for bxmesh.net (Zone Read and DNS Edit on bxmesh.net only, K23) isn't
made here either: an apply token able to mint tokens could mint any token on the account. It was
made once by hand, straight into OpenBao at `secret/platform-external-dns/bxmesh`, on 27 October
2026.

The names of BxMesh's sites aren't here: cluster-02's external-dns for bxmesh.net writes each one
from the app's own route (K23).

| File | What it is |
| --- | --- |
| `stacks/cloudflare/tunnel.tf` | BxMesh's own tunnel, remotely managed: `bxmesh.net` and `*.bxmesh.net` go to BxMesh's gateway in cluster-02, anything else gets a 404 (O59, O73, A23) |
| `stacks/cloudflare/access.tf` | Access, owner only by a one-time code, as on cluster-01: `bxmesh.net/admin`, the observers' approvals (O126), and `mqtt-admin.bxmesh.net`, the broker's dashboard (O123), taken over from cluster-01 |
| `stacks/cloudflare/email.tf` | bxmesh.net's MX to Google Workspace (O60) |
| `stacks/cloudflare/outputs.tf` | The tunnel's ID and CNAME target, the Access audiences, and the tunnel's token (sensitive) |
| `stacks/cloudflare/tofu.sh` | OpenTofu from the owner's laptop, its state credentials from the keychain |
| `stacks/cloudflare/to-openbao.sh` | Moves the tunnel's token from the state straight into OpenBao, once |
| `.github/workflows/tofu.yml` | Checks only: `fmt` and `validate`, no secrets (O169) |

## State

In its own R2 bucket in the owner's account, **`bxmesh-tofu-state`**, key `terraform.tfstate`,
encrypted by OpenTofu with a passphrase (O80). The bucket is made by hand before the first apply,
as cluster-02's was (O30); nothing here creates it.

## CI

Checks only, on GitHub's own runners: each pull request and each push to `main` runs `tofu fmt` and
`tofu validate`. CI has no secrets and no access to Cloudflare or the state.

**Applies run from your laptop** with `stacks/cloudflare/tofu.sh`, until cluster-02's own runners
exist (O169). Nothing that can change your Cloudflare account, or read the state, is ever in GitHub.

## Before the first apply (done 27 October 2026)

- **The bucket** `bxmesh-tofu-state`, in OC, like cluster-02's.
- **Its key pair**, Object Read & Write on that bucket only, in your keychain as
  `bxmesh-tofu-state-r2-access-key-id` and `bxmesh-tofu-state-r2-secret-access-key`.
- **The passphrase**, 48 random characters, in your keychain as `bxmesh-tofu-state-passphrase`.

None of them was printed, or written anywhere but the keychain. Cloudflare's own credentials are
the ones in your shell (O168).

## Applying

```sh
cd stacks/cloudflare
./tofu.sh init
./tofu.sh plan
./tofu.sh apply
```

## After the first apply

Move the tunnel's token into OpenBao, straight from the state, never printed (O57), with
cluster-terraform's `bao.sh` (it defaults to `~/repositories/zindello/cluster-terraform`):

```sh
cd stacks/cloudflare
./to-openbao.sh [path to cluster-terraform/stacks/openbao/bao.sh]
```

| Output | Goes to |
| --- | --- |
| `tunnel_token` | `secret/dmz-bxmesh-cloudflared/tunnel`, key `token` (cloudflared, O80) |

The rest aren't secrets: `./tofu.sh output` (in `stacks/cloudflare`) shows them. `admin_access_aud` is the observers app's
`ACCESS_AUD` (its `ACCESS_TEAM` is `zindello.cloudflareaccess.com`), and `tunnel_cname` is the
target external-dns writes for bxmesh.net.
