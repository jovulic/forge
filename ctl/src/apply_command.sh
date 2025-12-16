# shellcheck shell=bash

set -efo pipefail

echo "apply" | figlet

apply_system() {
	echo "system" | figlet
	local command=("nh" "os" "switch")

	if [[ -n "${args['--dry']}" ]]; then
		command+=("--dry")
	fi

	if [[ -z "${args['--yes']}" ]]; then
		command+=("--ask")
	fi

	if [[ -n "${args['--keep-going']}" ]]; then
		command+=("--keep-going")
	fi

	if [[ -n "${args['--repair']}" ]]; then
		command+=("--repair")
	fi

	if [[ -n "${args['--show-trace']}" ]]; then
		command+=("--show-trace")
	fi

	command+=(".")

	if [[ -n "${args[name]}" ]]; then
		command+=("${args[name]}")
	fi

	"${command[@]}"
}

apply_home() {
	echo "home" | figlet
	local command=("nh" "home" "switch")

	if [[ -n "${args['--dry']}" ]]; then
		command+=("--dry")
	fi

	if [[ -z "${args['--yes']}" ]]; then
		command+=("--ask")
	fi

	if [[ -n "${args['--keep-going']}" ]]; then
		command+=("--keep-going")
	fi

	if [[ -n "${args['--repair']}" ]]; then
		command+=("--repair")
	fi

	if [[ -n "${args['--show-trace']}" ]]; then
		command+=("--show-trace")
	fi

	command+=(".")

	if [[ -n "${args[name]}" ]]; then
		command+=("${args[name]}")
	fi

	"${command[@]}"
}

sudo -v # refresh sudo

# shellcheck disable=SC2154
name="${args[name]}"

case "$name" in
"system") apply_system ;;
"home") apply_home ;;
"")
	apply_system
	apply_home
	;;
"*")
	echo "invalid name ${args[name]}"
	exit 1
	;;
esac

# # Refresh sudo credentials if necessary.
# sudo -v
#
# # shellcheck disable=SC2154
# name="${args[name]}"
#
# case "$name" in
# "system") nixos-rebuild switch --sudo --flake . ;;
# "home") home-manager switch --flake . ;;
# "")
# 	echo "applying system configuration..."
# 	nixos-rebuild switch --option eval-cache false --sudo --flake .
# 	echo "finished applying system configuration"
#
# 	echo "applying home configuration..."
# 	home-manager switch --flake .
# 	echo "finished applying home configuration"
# 	;;
# "*")
# 	echo "invalid name ${args[name]}"
# 	exit 1
# 	;;
# esac
