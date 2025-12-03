{ pkgs, nix, ... }:
pkgs.callPackage
  (
    pkgs.fetchFromGitHub {
      owner = "jovulic";
      repo = "nix-shell-builtin";
      rev = "v2.1.1";
      hash = "sha256-rJi7Oe95/8DkVgxKxp4TbFG5UV+3km+Zs+WlG4L1+so=";
    }
    + "/plugin.nix"
  )
  {
    inherit nix;
  }
