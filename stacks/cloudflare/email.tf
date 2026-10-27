# bxmesh.net's mail goes to Google (O60): observers@bxmesh.net is a Google group (O38). Google's
# side is the owner's. The value is Google Workspace's current one, from its own docs
# ("Set up MX records for Google Workspace", checked 27 October 2026): one record, priority 1.
resource "cloudflare_dns_record" "mx_google" {
  zone_id  = local.zone_id
  name     = local.zone
  type     = "MX"
  content  = "smtp.google.com"
  priority = 1
  ttl      = 1 # automatic
  comment  = "Mail to Google Workspace (O60), managed by bxmesh/terraform"
}
