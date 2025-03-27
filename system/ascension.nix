{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.ascension;
in
with lib;
{
  options = {
    forge.system.ascension = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable ascension configuration.";
      };
    };
  };
  config =
    let
      ascension =
        let
          configDir = "/home/$USER/.config/projectascension";
          gameDir = "/home/$USER/ascension/projectascension";
          ascensionScript = pkgs.writeShellScript "ascension.sh" ''
            set -eo pipefail

            export WINEPREFIX="${configDir}/WoW"
            export WINEARCH=win32

            if [[ ! -d "${configDir}" ]]; then
              echo "Setting up ascension config directory (${configDir})."
              mkdir -p ${configDir}/WoW && cd ${configDir}
              wget https://dl.winehq.org/wine/wine-mono/6.3.0/wine-mono-6.3.0-x86.msi
              wine msiexec /i wine-mono-6.3.0-x86.msi
              winetricks win10 ie8 corefonts dotnet45 vcrun2015
            fi
            if [[ ! -d "${gameDir}" ]]; then
              echo "Setting up ascension game directory (${gameDir})."
              mkdir -p ${gameDir} && cd ${gameDir}
              wget https://download.ascension-patch.gg/update/ascension-launcher-111.AppImage
              chmod +x ascension-launcher-111.AppImage
            fi

            appimage-run ${gameDir}/ascension-launcher-111.AppImage
          '';
        in
        pkgs.buildFHSUserEnv {
          name = "ascension";
          targetPkgs = pkgs: [
            pkgs.wine
            pkgs.winetricks
            pkgs.mono
            pkgs.zlib
            pkgs.fuse
          ];
          runScript = ascensionScript;
        };
    in
    mkIf cfg.enable {
      environment.systemPackages = [
        ascension
      ];
    };
}
