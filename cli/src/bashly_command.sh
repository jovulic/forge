# shellcheck shell=bash

set -efo pipefail

root=$(git rev-parse --show-toplevel)
(cd "$root/cli" && bashly generate)
direnv reload
