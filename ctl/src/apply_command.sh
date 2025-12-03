# shellcheck shell=bash

set -efo pipefail

echo "apply" | figlet

# Refresh sudo credentials if necessary.
sudo -v

# shellcheck disable=SC2154
name="${args[name]}"

case "$name" in
"system") nixos-rebuild switch --sudo --flake . ;;
"home") home-manager switch --flake . ;;
"")
	echo "Applying system configuration..."
	nixos-rebuild switch --option eval-cache false --sudo --flake .
	# nixos-rebuild switch --sudo --flake .
	echo "Finished applying system configuration."

	echo "Applying home configuration..."
	home-manager switch --flake .
	echo "Finished applying home configuration."
	;;
"*")
	echo "Invalid name ${args[name]}."
	exit 1
	;;
esac
