{ pkgs, ... }:
let
  nix-shell-builtin = pkgs.callPackage ./nix-shell-builtin { };
  mcp-hub = pkgs.callPackage ./mcp-hub { };
  plover = pkgs.callPackage ./plover { };
  exhaustive = pkgs.callPackage ./exhaustive { };
  jackify = pkgs.callPackage ./jackify { };
in
{
  inherit nix-shell-builtin;
  inherit mcp-hub;
  inherit plover;
  inherit exhaustive;
  inherit jackify;
}
