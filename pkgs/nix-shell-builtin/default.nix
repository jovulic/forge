{ pkgs, ... }:
pkgs.callPackage (
  pkgs.fetchFromGitHub {
    owner = "jovulic";
    repo = "nix-shell-builtin";
    rev = "v1.0.2";
    hash = "sha256-n/g8iRzjgG+6y7uLiM3IRo4C1cbtrMS29zgLjdFiaCs=";
  }
  + "/plugin.nix"
) { }
