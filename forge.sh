# shellcheck shell=bash

WORKDIR=~/forge

if [ -n "$INNIXSHELLHOME" ]; then
  echo "You are in a nix shell that redirected home!"
  echo "forge will not work from here properly."
  exit 1
fi

case $1 in
"run")
  shift
  pushd "$WORKDIR" >/dev/null || exit
  ctl "$@"
  popd >/dev/null || exit
  ;;
"inspect")
  shift
  pushd "$WORKDIR" >/dev/null || exit
  nix-inspect
  popd >/dev/null || exit
  ;;
"index")
  shift
  if [ "$1" = "find" ]; then
    shift
    nix-index locate "$1"
  else
    nix-index
  fi
  ;;
"packages")
  shift
  nix-search -dj "$@" | jq -cr '.package_attr_name' | fzf --preview="nix-search -d -m1 {}"
  ;;
"options")
  shift
  if [ "$1" = "home" ]; then
    shift
    manix --source hm-options "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix {}" | xargs manix
  else
    manix --source nixos-options "" | grep '^# ' | sed 's/^# \(.*\) (.*/\1/;s/ (.*//;s/^# //' | fzf --preview="manix {}" | xargs manix
  fi
  ;;
*)
  echo "Usage:"
  echo "  forge <command> [arguments]"
  echo ""
  echo "Commands:"
  echo "  run      - Run a forge ctl command."
  echo "  packages - Search over packages."
  echo "  options  - Search over options."
  ;;
esac
