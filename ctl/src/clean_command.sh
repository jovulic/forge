# shellcheck shell=bash

set -efo pipefail

echo "clean" | figlet

# Refresh sudo credentials if necessary.
sudo -v

if [[ -n "${args[--menu]}" ]]; then
	echo "cleaning menu"
	sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
	echo "finished cleaning menu"
fi

echo "running garbage collection"
nix-store --gc
echo "finished garbage collection"

if [[ -n "${args[--optimize]}" ]]; then
	echo "deduplication running... This may take awhile"
	nix-store --optimise
	echo "finished deduplication"
fi
