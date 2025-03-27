# shellcheck shell=bash

set -efo pipefail

echo "update" | figlet

nix flake update
