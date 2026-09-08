{ pkgs, ... }:
let
  nix-shell-builtin = pkgs.callPackage ./nix-shell-builtin { };
  mcp-hub = pkgs.callPackage ./mcp-hub { };
  plover = pkgs.callPackage ./plover { };
  exhaustive = pkgs.callPackage ./exhaustive { };
  jackify = pkgs.callPackage ./jackify { };
  typescript-svelte-plugin = pkgs.callPackage ./typescript-svelte-plugin { };
in
{
  inherit nix-shell-builtin;
  inherit mcp-hub;
  inherit plover;
  inherit exhaustive;
  inherit jackify;
  inherit typescript-svelte-plugin;
}
