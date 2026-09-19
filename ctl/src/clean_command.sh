# shellcheck shell=bash

set -efo pipefail

echo "clean" | figlet

sudo -v # refresh sudo

is_darwin() {
	[[ "$(uname)" == "Darwin" ]]
}

if is_darwin; then
	echo "Running macOS/darwin garbage collection..."

	if [[ -n "${args['--dry']}" ]]; then
		echo "Dry-run: Would run nix-collect-garbage -d"
		echo "Dry-run: Would run nix-store --gc"
		if [[ -n "${args['--optimise']}" ]]; then
			echo "Dry-run: Would run nix-store --optimise"
		fi
	else
		if [[ -z "${args['--no-gc']}" ]]; then
			echo "Pruning older profile generations..."
			nix-collect-garbage -d
			echo "Running Nix store garbage collection..."
			nix-store --gc
		fi

		if [[ -n "${args['--optimise']}" ]]; then
			echo "Optimising Nix store (deduplication)..."
			nix-store --optimise
		fi
	fi
else
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
fi
