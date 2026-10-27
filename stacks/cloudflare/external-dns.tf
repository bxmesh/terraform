# The token for cluster-02's second external-dns, the one for bxmesh.net only (K23): it reads the
# zone and edits its records, and nothing else. to-openbao.sh moves it into OpenBao after the
# apply. An account token, so it doesn't depend on one person's login.
resource "cloudflare_account_token" "external_dns" {
  account_id = local.account_id
  name       = "cluster-02 external-dns: bxmesh.net DNS"

  policies = [{
    effect = "allow"
    permission_groups = [
      { id = "c8fed203ed3043cba015a93ad1616f1f" }, # Zone Read
      { id = "4755a26eedb94da69e1066d98aa820be" }, # DNS Write
    ]
    resources = jsonencode({
      "com.cloudflare.api.account.zone.${local.zone_id}" = "*"
    })
  }]
}
