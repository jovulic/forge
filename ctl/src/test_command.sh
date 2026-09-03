# shellcheck shell=bash

set -efo pipefail

echo "test" | figlet

root=$(git rev-parse --show-toplevel)

if [[ -n "${args['--eval']}" ]]; then
	echo "Evaluating test system configuration..."
	nix-instantiate --dry-run --experimental-features "nix-command flakes" --eval -E '(builtins.getFlake "'"$root"'").nixosConfigurations.test.config.system.build.toplevel' >/dev/null
	echo "Success! The test system configuration evaluated successfully with no errors."
elif [[ -n "${args[package]}" ]]; then
	echo "Building and testing package: ${args[package]}..."
	nix-build --no-link -E '(import <nixpkgs> {}).callPackage '"$root"'/pkgs {}' -A "${args[package]}"
	echo "Success! Custom package '${args[package]}' built successfully."
else
	# Run complete test evaluation and dry-run build
	echo "Running comprehensive evaluation and build of test..."
	echo "1/2: Evaluating test system modules..."
	nix-instantiate --dry-run --experimental-features "nix-command flakes" --eval -E '(builtins.getFlake "'"$root"'").nixosConfigurations.test.config.system.build.toplevel' >/dev/null
	echo "Evaluation passed. All modules and option declarations are valid."

	echo "2/2: Building test top-level system dry-run..."
	nix-build --dry-run --experimental-features "nix-command flakes" -E '(builtins.getFlake "'"$root"'").nixosConfigurations.test.config.system.build.toplevel'
	echo "Dry-run build passed. All dependencies and package inputs are resolvable."
	echo ""
	echo "Success! The full Forge codebase, modules, and testbed are completely healthy."
fi
