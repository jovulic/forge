{ pkgs, ... }:
let
  nix-shell-plugin = pkgs.callPackage ./nix-shell-plugin { };
  plover = pkgs.callPackage ./plover { };
in
{
  inherit nix-shell-plugin;
  inherit plover;
}
