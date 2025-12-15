# shellcheck shell=bash

set -efo pipefail

echo "clean" | figlet

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

# Refresh sudo credentials if necessary.
# sudo -v
#
# if [[ -n "${args[--menu]}" ]]; then
# 	echo "cleaning menu"
# 	sudo nix-env --delete-generations old --profile /nix/var/nix/profiles/system
# 	echo "finished cleaning menu"
# fi
#
# echo "running garbage collection"
# nix-store --gc
# echo "finished garbage collection"
#
# if [[ -n "${args[--optimize]}" ]]; then
# 	echo "deduplication running... This may take awhile"
# 	nix-store --optimise
# 	echo "finished deduplication"
# fi
