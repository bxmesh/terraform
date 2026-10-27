# The facts this repo builds on. Each was read from Cloudflare's API on 27 October 2026.
locals {
  # The owner's Cloudflare account, which holds the bxmesh.net zone (O59).
  account_id = "a4bcb99cdf5a071a4c78f941a5b91f6f"
  zone_id    = "55d4f65a442dc234a42cb27a15858b38" # bxmesh.net
  zone       = "bxmesh.net"

  # Who gets past Access: the owner, BxMesh's custodian (O11), as on cluster-01 today.
  owner_email = "josh@zindello.com.au"

  # The account's One-time PIN login, which cluster-01's Access apps use.
  one_time_pin_idp = "204dbafd-acb2-4ff7-9d31-3eb7dc6d2f39"

  # BxMesh's own gateway in cluster-02, for bxmesh.net only (O73, A23).
  gateway = "http://gateway-bxmesh.platform-gateways.svc.cluster.local:80"
}
