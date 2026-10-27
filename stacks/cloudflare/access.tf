# Cloudflare Access in front of BxMesh's admin pages: only the owner gets in, by a one-time code
# sent to them, as on cluster-01 today. Each app exists before its hostname's DNS does.

resource "cloudflare_zero_trust_access_policy" "owner" {
  account_id = local.account_id
  name       = "BxMesh: the owner only"
  decision   = "allow"
  include    = [{ email = { email = local.owner_email } }]
}

# The observers' approvals, on bxmesh.net's own path (O124, O126). The observers app checks this
# app's audience (ACCESS_AUD): the output `admin_access_aud`.
resource "cloudflare_zero_trust_access_application" "admin" {
  account_id                = local.account_id
  name                      = "BxMesh observer approvals"
  type                      = "self_hosted"
  domain                    = "${local.zone}/admin"
  destinations              = [{ type = "public", uri = "${local.zone}/admin" }]
  session_duration          = "24h"
  allowed_idps              = [local.one_time_pin_idp]
  auto_redirect_to_identity = true
  policies                  = [{ id = cloudflare_zero_trust_access_policy.owner.id, precedence = 1 }]
}

# The broker's dashboard (O123). cluster-01 made this app; it's taken over here, not made again.
import {
  to = cloudflare_zero_trust_access_application.mqtt_admin
  id = "accounts/${local.account_id}/43a9540c-3900-4c00-ad87-488855014529"
}

resource "cloudflare_zero_trust_access_application" "mqtt_admin" {
  account_id                = local.account_id
  name                      = "BXMesh broker dashboard"
  type                      = "self_hosted"
  domain                    = "mqtt-admin.${local.zone}"
  destinations              = [{ type = "public", uri = "mqtt-admin.${local.zone}" }]
  session_duration          = "24h"
  allowed_idps              = [local.one_time_pin_idp]
  auto_redirect_to_identity = true
  enable_binding_cookie     = false
  options_preflight_bypass  = false
  policies                  = [{ id = cloudflare_zero_trust_access_policy.owner.id, precedence = 1 }]
}
