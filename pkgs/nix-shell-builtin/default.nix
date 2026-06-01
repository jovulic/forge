{ pkgs, nix, ... }:
pkgs.callPackage
  (
    pkgs.fetchFromGitHub {
      owner = "jovulic";
      repo = "nix-shell-builtin";
      rev = "v2.2.0";
      hash = "sha256-NWVow1t3ehloLUAgZqckcJGIKgvxRu3DUtWJiK7XGNc=";
    }
    + "/plugin.nix"
  )
  {
    inherit nix;
  }
