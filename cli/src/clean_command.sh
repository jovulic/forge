# shellcheck shell=bash

set -efo pipefail

echo "clean" | figlet

sudo -v # refresh sudo

if ! command -v nh >/dev/null 2>&1; then
	echo "error: 'nh' is not installed. Please install it or use standard nix tools." >&2
	exit 1
fi
command=("nh" "clean" "all" "--keep-one")

if [[ -n "${args['--dry']}" ]]; then
	command+=("--dry")
fi

if [[ -z "${args['--yes']}" ]]; then
	command+=("--ask")
fi

if [[ -n "${args['--no-gc']}" ]]; then
	command+=("--no-gc")
fi

if [[ -n "${args['--no-gcroots']}" ]]; then
	command+=("--no-gcroots")
fi

if [[ -n "${args['--optimise']}" ]]; then
	command+=("--optimise")
fi

"${command[@]}"
