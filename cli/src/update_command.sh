# shellcheck shell=bash

set -efo pipefail

echo "update" | figlet

command=("nix" "flake" "update")

if [[ -n "${args['name']}" ]]; then
  command+=("${args['name']}")
fi

"${command[@]}"
