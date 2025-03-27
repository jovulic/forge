# shellcheck shell=bash

set -efo pipefail

echo "clean" | figlet

# Refresh sudo credentials if necessary.
sudo -v

if [[ -n "${args[--menu]}" ]]; then
	echo "Cleaning menu."
	sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
	echo "Finished cleaning menu."
fi

echo "Running garbage collection."
nix-store --gc
echo "Finished garbage collection."

if [[ -n "${args[--optimize]}" ]]; then
	echo "Deduplication running... This may take awhile."
	nix-store --optimise
	echo "Finished deduplication."
fi
