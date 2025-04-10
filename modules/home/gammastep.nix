{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.gammastep;
in
with lib;
{
  options = {
    forge.home.gammastep = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gammastep configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      gammastep = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Reduce bluelight with gammastep.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${pkgs.gammastep}/bin/gammastep -v";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
