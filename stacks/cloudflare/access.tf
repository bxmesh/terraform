# Cloudflare Access in front of BxMesh's admin pages: only the owner gets in. The observers'
# approvals sign in with Google (the owner, 2 November 2026); the broker's dashboard still by a
# one-time code sent to them, as on cluster-01. Each app exists before its hostname's DNS does.

# The account's Google login method, found by type, read and not owned: the owner added it in the
# Zero Trust dashboard with their own OAuth client (as cluster-02's Argo CD uses), so its secret
# never enters this stack's state. Cloudflare's "google" (any Google account) or "google-apps"
# (Google Workspace); exactly one must exist.
data "cloudflare_zero_trust_access_identity_providers" "all" {
  account_id = local.account_id
}

locals {
  google_idp = one([
    for p in data.cloudflare_zero_trust_access_identity_providers.all.result : p.id
    if contains(["google", "google-apps"], p.type)
  ])
}

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
  allowed_idps              = [local.google_idp]
  auto_redirect_to_identity = true
  policies                  = [{ id = cloudflare_zero_trust_access_policy.owner.id, precedence = 1 }]

  lifecycle {
    precondition {
      condition     = local.google_idp != null
      error_message = "No Google login method on the account: add it in Zero Trust (Settings, Authentication, Login methods) first."
    }
  }
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
