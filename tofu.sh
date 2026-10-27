#!/usr/bin/env bash
# Runs OpenTofu for this repo from the owner's laptop, with the state's key pair and passphrase read
# from the macOS keychain for this one process: never printed, never written to disk. Applies run
# in CI; this is for reading the state (to-openbao.sh) and for a local plan.
#   ./tofu.sh init | plan | output ...
# A local plan also needs Cloudflare credentials in the environment (CLOUDFLARE_API_TOKEN, or
# CLOUDFLARE_EMAIL and CLOUDFLARE_API_KEY).
set -euo pipefail
cd "$(dirname "$0")"

key() { security find-generic-password -s "$1" -w; }

AWS_ACCESS_KEY_ID="$(key bxmesh-tofu-state-r2-access-key-id)" \
AWS_SECRET_ACCESS_KEY="$(key bxmesh-tofu-state-r2-secret-access-key)" \
TF_VAR_state_passphrase="$(key bxmesh-tofu-state-passphrase)" \
  exec tofu "$@"
