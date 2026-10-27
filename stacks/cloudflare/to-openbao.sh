#!/usr/bin/env bash
# Moves the tunnel's token into OpenBao, once, after the first apply: straight
# from the encrypted state into OpenBao through cluster-terraform's bao.sh, never printed and never
# written to disk (O57). Stops before writing anything empty.
#   ./to-openbao.sh [path to cluster-terraform's stacks/openbao/bao.sh]
set -euo pipefail
cd "$(dirname "$0")"
bao="${1:-$HOME/repositories/zindello/cluster-terraform/stacks/openbao/bao.sh}"

move() { # <output> <OpenBao path> <key>
  local value
  value="$(./tofu.sh output -raw "$1")"
  [ -n "$value" ] || { echo "$1 is empty: nothing written." >&2; exit 1; }
  printf '%s' "$value" | "$bao" kv put "$2" "$3=-"
  echo "$1 -> $2 ($3)"
}

move tunnel_token secret/dmz-bxmesh-cloudflared/tunnel token
