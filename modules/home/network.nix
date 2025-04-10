{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.network;
in
with lib;
{
  options = {
    forge.home.network = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable network configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      nm-applet = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "iwgtk applet.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${pkgs.iwgtk}/bin/iwgtk -i";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
