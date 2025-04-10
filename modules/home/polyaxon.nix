{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.polyaxon;
in
with lib;
{
  options = {
    forge.home.polyaxon = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable polyaxon configuration.";
      };
    };
  };
  config =
    let
      venvDir = "${config.home.homeDirectory}/.nix-venv/polyaxon";
      polyaxon = pkgs.buildFHSUserEnv {
        name = "polyaxon";
        targetPkgs = pkgs: [
          (pkgs.python3.withPackages (p: [
            p.pip
            p.virtualenv
          ]))
        ];
        profile = ''
          set -euo pipefail

          if [[ ! -d "${venvDir}" ]]; then
            echo "Creating new venv environment in path: '${venvDir}'"
            python3 -m venv "${venvDir}"
          fi

          source "${venvDir}/bin/activate"

          if [[ ! -f "${venvDir}/bin/polyaxon" ]]; then
            echo "Installing polyaxon."
            pip install "polyaxon[numpy]"
          fi
        '';
        runScript = "polyaxon";
      };
    in
    # $ nix-shell -E 'with import <nixpkgs> {}; (pkgs.buildFHSUserEnv { name = "polyaxon"; targetPkgs = pkgs: with pkgs; [ (python3.withPackages (p: with p; [ pip virtualenv certifi ])) ]; runScript = "bash"; }).env'
    mkIf cfg.enable {
      home.packages = [
        polyaxon
      ];
    };
}
