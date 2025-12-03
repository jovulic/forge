{ pkgs, ... }:
let
  nix-shell-builtin = pkgs.callPackage ./nix-shell-builtin { };
  plover = pkgs.callPackage ./plover { };
  exhaustive = pkgs.callPackage ./exhaustive{ };
in
{
  inherit nix-shell-builtin;
  inherit plover;
  inherit exhaustive;
}
