{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.curseforge;
in
with lib;
{
  options = {
    forge.system.curseforge = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable curseforge configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      (
        let
          dir = fetchzip {
            url = "https://curseforge.overwolf.com/downloads/curseforge-latest-linux.zip";
            hash = "sha256-KhhLFqFDUa9bc0Zqu0UXF9SZa1L8OjB1vAAuYhjH97s=";
          };
          file = "${dir}/CurseForge-0.240.3-15214.AppImage";
        in
        pkgs.appimageTools.wrapType2 {
          name = "curseforge";
          src = file;
        }
      )
    ];
  };
}
