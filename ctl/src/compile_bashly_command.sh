# shellcheck shell=bash

set -efo pipefail

echo "compile:bashly" | figlet

# ref: https://github.com/NixOS/nixpkgs/blob/master/doc/languages-frameworks/ruby.section.md

if [[ -n "${args[--init]}" ]]; then
	(
		cd pkgs/bashly
		cat <<-EOF >Gemfile
			source "https://rubygems.org"
			gem "bashly"
		EOF
	)
fi

(
	cd pkgs/bashly
	bundle lock
	bundix
)
