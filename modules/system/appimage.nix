{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.appimage;
in
with lib;
{
  options = {
    forge.system.appimage = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable appimage configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.appimage-run # APPIMAGE_DEBUG_EXEC=bash appimage-run <appimage>
    ];
  };
}
