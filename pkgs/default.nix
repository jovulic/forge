{ pkgs, ... }:
let
  nix-shell-builtin = pkgs.callPackage ./nix-shell-builtin { };
  plover = pkgs.callPackage ./plover { };
in
{
  inherit nix-shell-builtin;
  inherit plover;
}
