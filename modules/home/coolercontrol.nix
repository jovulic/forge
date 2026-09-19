{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.coolercontrol;
in
with lib;
{
  options = {
    forge.home.coolercontrol = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable coolercontrol configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      coolercontrol = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Cooling control by CoolerControl.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${pkgs.coolercontrol.coolercontrol-gui}/bin/coolercontrol";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
