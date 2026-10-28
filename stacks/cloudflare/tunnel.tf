# BxMesh's own tunnel (O59), separate from cluster-02's for the owner's domains. Its connector is
# cluster-02's cloudflared in dmz-bxmesh-cloudflared. Remotely managed: its routes are set here,
# not in cloudflared's own config.
resource "cloudflare_zero_trust_tunnel_cloudflared" "bxmesh" {
  account_id = local.account_id
  name       = "bxmesh"
  config_src = "cloudflare"
}

# Every bxmesh.net hostname goes to BxMesh's gateway, which routes it by hostname (O73). Anything
# else that reaches the tunnel gets a 404. Which hostnames point here is decided by external-dns,
# from each app's own routes (K23).
resource "cloudflare_zero_trust_tunnel_cloudflared_config" "bxmesh" {
  account_id = local.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.bxmesh.id

  config = {
    ingress = [
      { hostname = local.zone, service = local.gateway },
      { hostname = "*.${local.zone}", service = local.gateway },
      { service = "http_status:404" },
    ]
  }
}

# The token cloudflared runs with. It reaches OpenBao by the owner's hand, once (README).
data "cloudflare_zero_trust_tunnel_cloudflared_token" "bxmesh" {
  account_id = local.account_id
  tunnel_id  = cloudflare_zero_trust_tunnel_cloudflared.bxmesh.id
}
