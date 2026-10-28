# The Turnstile widget on the observers' form, bxmesh.net/join. It was made by hand for cluster-01,
# when the form was at observers.bxmesh.net, so it's taken over here, not made again: the site key
# stays 0x4AAAAAAFjcsp1S1dOQEz1J (the observers app's TURNSTILE_SITEKEY) and its secret, already in
# OpenBao, stays valid.
#
# Now that the form is on bxmesh.net (O126), the widget fails there with error 110200, "Domain not
# authorized". A hostname covers its subdomains, so bxmesh.net alone allows both bxmesh.net/join and
# observers.bxmesh.net.
import {
  to = cloudflare_turnstile_widget.observers
  id = "${local.account_id}/0x4AAAAAAFjcsp1S1dOQEz1J"
}

resource "cloudflare_turnstile_widget" "observers" {
  account_id = local.account_id
  # name and mode aren't known from here: the widget was made in the dashboard. Set them to what
  # the dashboard shows before planning, so the plan changes only the domains.
  name    = "BXMesh observers"
  mode    = "managed"
  domains = [local.zone]
}
