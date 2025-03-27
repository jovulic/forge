# shellcheck shell=bash

set -efo pipefail

root=$(git rev-parse --show-toplevel)
(cd "$root/ctl" && bashly generate)
direnv reload
