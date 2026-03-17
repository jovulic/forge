{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.openrazer;
in
with lib;
{
  options = {
    forge.home.openrazer = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable openrazer configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      openrazer = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Openrazer control by polychromatic.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${pkgs.polychromatic}/bin/polychromatic-tray-applet";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
