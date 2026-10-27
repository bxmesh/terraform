output "tunnel_id" {
  description = "BxMesh's tunnel. external-dns points bxmesh.net's names at tunnel_cname."
  value       = cloudflare_zero_trust_tunnel_cloudflared.bxmesh.id
}

output "tunnel_cname" {
  description = "The target for every proxied bxmesh.net record external-dns writes."
  value       = "${cloudflare_zero_trust_tunnel_cloudflared.bxmesh.id}.cfargotunnel.com"
}

output "admin_access_aud" {
  description = "The audience of the Access app on bxmesh.net/admin: the observers app's ACCESS_AUD (its ACCESS_TEAM is zindello.cloudflareaccess.com)."
  value       = cloudflare_zero_trust_access_application.admin.aud
}

output "mqtt_admin_access_aud" {
  description = "The audience of the Access app on mqtt-admin.bxmesh.net."
  value       = cloudflare_zero_trust_access_application.mqtt_admin.aud
}

# The two credentials cluster-02 needs. They go straight into OpenBao, never printed
# (to-openbao.sh).

output "tunnel_token" {
  description = "cloudflared's token: OpenBao secret/dmz-bxmesh-cloudflared/tunnel, key token."
  value       = data.cloudflare_zero_trust_tunnel_cloudflared_token.bxmesh.token
  sensitive   = true
}
