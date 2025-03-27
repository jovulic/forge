{ pkgs, ... }:
pkgs.appimageTools.wrapType1 {
  name = "plover";
  version = "v4.0.0.dev12";
  src = pkgs.fetchurl {
    url = "https://github.com/openstenoproject/plover/releases/download/v4.0.0.dev12/plover-4.0.0.dev12-x86_64.AppImage";
    hash = "sha256-lg2+RN9X2hoe7QM1EeLgqW9M2yZEYixbyatFlhbD+wo=";
  };
}
# $ nix-shell -E 'with import <nixpkgs> {}; (pkgs.buildFHSUserEnv { name = "plover"; targetPkgs = pkgs: with pkgs; [ python3 python3Packages.pip python3Packages.virtualenv ]; runScript = "bash"; }).env'
