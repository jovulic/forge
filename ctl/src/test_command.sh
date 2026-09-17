# shellcheck shell=bash

set -efo pipefail

root=$(git rev-parse --show-toplevel)

get_default_host() {
	if [[ "$(uname)" == "Darwin" ]]; then
		echo "macbook"
	else
		local hn
		hn=$(hostname -s 2>/dev/null || hostname 2>/dev/null || echo "licious")
		if [[ "$hn" =~ ^(licious|expert|macbook|test)$ ]]; then
			echo "$hn"
		else
			echo "test" # default fallback
		fi
	fi
}

is_darwin_host() {
	[[ "$1" == "macbook" ]]
}

# shellcheck disable=SC2154
if [[ -n "${args[package]:-}" ]]; then
	echo "Building custom package: ${args[package]}..."
	nix-build --no-link -E '(import <nixpkgs> {}).callPackage '"$root"'/pkgs {}' -A "${args[package]}"
	echo "Success! Custom package '${args[package]}' built successfully."
	exit 0
fi

# shellcheck disable=SC2154
host="${args[--host]:-$(get_default_host)}"

if is_darwin_host "$host"; then
	target_expr=".#darwinConfigurations.${host}.system"
else
	target_expr=".#nixosConfigurations.${host}.config.system.build.toplevel"
fi

# shellcheck disable=SC2154
if [[ -n "${args[--eval]:-}" ]]; then
	echo "Evaluating host: $host..."
	nix eval --experimental-features "nix-command flakes" "$target_expr" --show-trace >/dev/null
	echo "Success! Host configuration '$host' evaluated successfully with no errors."
else
	echo "Evaluating host: $host..."
	nix eval --experimental-features "nix-command flakes" "$target_expr" --show-trace >/dev/null
	echo "Dry-run building host: $host..."
	nix build --dry-run --experimental-features "nix-command flakes" "$target_expr"
	echo "Success! Host configuration '$host' is fully healthy."
fi
