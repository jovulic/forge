{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.corectrl;
in
with lib;
{
  options = {
    forge.home.corectrl = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable corectrl configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      corectrl = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Cooling control by corectrl.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${pkgs.corectrl}/bin/corectrl --minimize-systray";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
