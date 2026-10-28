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

# Google Workspace's sending records, the values the owner took from the Workspace admin console
# on 28 October 2026. Observers' mail goes out through Cloudflare Email Sending instead, whose
# envelope domain is cf-bounce.bxmesh.net with its own SPF and DKIM (made by Cloudflare's
# onboarding), so this SPF doesn't need to include Cloudflare's. TXT content is quoted; Cloudflare
# splits a quoted string over 255 characters itself.
resource "cloudflare_dns_record" "spf_google" {
  zone_id = local.zone_id
  name    = local.zone
  type    = "TXT"
  content = "\"v=spf1 include:_spf.google.com ~all\""
  ttl     = 1 # automatic
  comment = "SPF for Google Workspace, managed by bxmesh/terraform"
}

resource "cloudflare_dns_record" "dkim_google" {
  zone_id = local.zone_id
  name    = "google._domainkey.${local.zone}"
  type    = "TXT"
  content = "\"v=DKIM1; k=rsa; p=MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEAypBVYw31aO4C/K8ho1Ezh07lsVj1YZPxpksN9Xl1/LiI2a5DHBFH4Ecm438Vs0hK9ONCdb5zw4FloHTU8otccmhqlCT07X2GmxR0SU4Xewv/fTnQ9rY3dsKZvFr4pYL8bPbNl3/pM7GzainE/A4Jq2D8w4yEOxF1tjteFd5wX8QkqVitU7iR5TNN0oJQYwo+4bj8u+AEKdQfWP0y9CyVn+y0nGD2vmSXD436e2klShokdGyu/8IoWOKmLSMVAEmC+yawI9qVeIdwG4DQZUKDT5ust/2rVk7YtFYCaoHrmzr8qywbsFLf6bPu22/NtjBrGQSdTmuwv3CKzgYezTX2vQIDAQAB\""
  ttl     = 1 # automatic
  comment = "DKIM for Google Workspace, managed by bxmesh/terraform"
}
