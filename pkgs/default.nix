{ pkgs, ... }:
let
  nix-shell-builtin = pkgs.callPackage ./nix-shell-builtin { };
  mcp-hub = pkgs.callPackage ./mcp-hub { };
  plover = pkgs.callPackage ./plover { };
  exhaustive = pkgs.callPackage ./exhaustive { };
  hd2arsenal = pkgs.callPackage ./hd2arsenal { };
  jackify = pkgs.callPackage ./jackify { };
  volt-gui = pkgs.callPackage ./volt-gui { };
  typescript-svelte-plugin = pkgs.callPackage ./typescript-svelte-plugin { };
in
{
  inherit nix-shell-builtin;
  inherit mcp-hub;
  inherit plover;
  inherit exhaustive;
  inherit hd2arsenal;
  inherit jackify;
  inherit volt-gui;
  inherit typescript-svelte-plugin;
}
