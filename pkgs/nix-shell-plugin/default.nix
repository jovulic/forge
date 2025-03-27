{ pkgs, ... }:
pkgs.callPackage (
  pkgs.fetchFromGitHub {
    owner = "jovulic";
    repo = "nix-shell-plugin";
    rev = "v1.0.1";
    hash = "sha256-RIEGJ8xRV9T79amr96WJ/1rtQSHhkkRPbKy9gG78Mg4=";
  }
  + "/plugin.nix"
) { }
