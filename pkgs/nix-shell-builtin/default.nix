{ pkgs, nix, ... }:
pkgs.callPackage
  (
    pkgs.fetchFromGitHub {
      owner = "jovulic";
      repo = "nix-shell-builtin";
      rev = "v2.1.1";
      hash = "sha256-YG9fKpQWBTNHxiqRaDi3di/gIkGleOlAA6kqKyrCRwY=";
    }
    + "/plugin.nix"
  )
  {
    inherit nix;
  }
