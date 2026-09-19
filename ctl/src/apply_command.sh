# shellcheck shell=bash

set -efo pipefail

echo "apply" | figlet

is_darwin() {
	[[ "$(uname)" == "Darwin" ]]
}

apply_system() {
	echo "system" | figlet
	if is_darwin; then
		local host="${args[host]:-macbook}"
		local subcommand="switch"
		if [[ -n "${args['--dry']}" ]]; then
			subcommand="build"
		fi
		local command=("darwin-rebuild" "$subcommand" "--flake" ".#$host")

		if [[ -n "${args['--show-trace']}" ]]; then
			command+=("--show-trace")
		fi

		if [[ -n "${args['--debug']}" ]]; then
			command+=("-v")
		fi

		echo "Running: ${command[*]}"
		"${command[@]}"
	else
		if ! command -v nh >/dev/null 2>&1; then
			echo "error: 'nh' is not installed. Please install it or use standard nix tools." >&2
			exit 1
		fi
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

		if [[ -n "${args['--debug']}" ]]; then
			command+=("--show-activation-logs" "-v")
		fi

		command+=(".")

		if [[ -n "${args[host]}" ]]; then
			command+=("${args[host]}")
		fi

		"${command[@]}"
	fi
}

apply_home() {
	echo "home" | figlet
	if is_darwin; then
		echo "On macOS, Home Manager is integrated into nix-darwin."
	else
		if ! command -v nh >/dev/null 2>&1; then
			echo "error: 'nh' (Nix Helper) is not installed. Please install it or use standard home-manager." >&2
			exit 1
		fi
		local command=("nh" "home" "switch" "-b" "backup")

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

		if [[ -n "${args['--debug']}" ]]; then
			command+=("--show-activation-logs" "-v")
		fi

		command+=(".")

		if [[ -n "${args[host]}" ]]; then
			command+=("${args[host]}")
		fi

		"${command[@]}"
	fi
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
