#!/usr/bin/env bash
# Runs OpenTofu for this repo from the owner's laptop, the only place it's applied from (O169).
# The state's key pair and passphrase are read from the macOS keychain for this one process:
# never printed, never written to disk. Cloudflare's credentials come from your shell
# (CLOUDFLARE_EMAIL and CLOUDFLARE_API_KEY, as for cluster-terraform's cloudflare stack, O168).
#   ./tofu.sh init | plan | apply | output ...
set -euo pipefail
cd "$(dirname "$0")"

key() { security find-generic-password -s "$1" -w; }

AWS_ACCESS_KEY_ID="$(key bxmesh-tofu-state-r2-access-key-id)" \
AWS_SECRET_ACCESS_KEY="$(key bxmesh-tofu-state-r2-secret-access-key)" \
TF_VAR_state_passphrase="$(key bxmesh-tofu-state-passphrase)" \
  exec tofu "$@"
