{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.openrgb;
in
with lib;
{
  options = {
    forge.home.openrgb = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable openrgb configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      openrgb = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Light control by OpenRGB.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${pkgs.openrgb}/bin/openrgb --startminimized";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
