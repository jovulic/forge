# shellcheck shell=bash

set -efo pipefail

attribute="${args[attribute]}"
root=$(git rev-parse --show-toplevel)

echo "Looking up attribute: ${attribute}..."

# We construct and run a Nix expression that resolves the position of the
# attribute. We then print the file path and line number, and print the
# context/source code.
# shellcheck disable=SC2016
result=$(nix-instantiate --experimental-features "nix-command flakes" \
  --eval \
  --argstr root "$root" \
  --argstr attribute "$attribute" \
  -E '
    { root, attribute }:
    let
      flake = builtins.getFlake root;
      pkgs = flake.inputs.nixpkgs.legacyPackages.x86_64-linux;
      lib = pkgs.lib;
      attrPath = builtins.filter (x: !builtins.isList x) (builtins.split "\\." attribute);
      pathLength = builtins.length attrPath;
      parentPath = lib.take (pathLength - 1) attrPath;
      attrName = lib.last attrPath;
      parentSet = lib.attrByPath parentPath pkgs pkgs;
      pos = builtins.unsafeGetAttrPos attrName parentSet;
    in
      if pos == null then
        "null"
      else
        "${toString pos.file}:${toString pos.line}"
  ' 2>/dev/null)

# Strip leading and trailing quotes safely.
result=$(echo "$result" | tr -d '"')

if [[ "$result" == "null" || -z "$result" ]]; then
  echo "Error: Attribute '${attribute}' not found or position not available."
  exit 1
fi

# Split by the last colon.
file="${result%:*}"
line="${result##*:}"

echo ""
echo "Found definition in Nixpkgs:"
echo "  File:   ${file}"
echo "  Line:   ${line}"
echo ""

# Print a small excerpt around that line if the file is readable.
if [[ -f "$file" ]]; then
  echo "Context (lines $((line - 2)) to $((line + 8))):"
  echo "----------------------------------------"
  sed -n "$((line - 2)),$((line + 8))p" "$file" | sed 's/^/  /'
  echo "----------------------------------------"
fi
