{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.udiskie;
in
with lib;
{
  options = {
    forge.home.udiskie = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable udiskie configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      udiskie = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Auto usb mounting by udiskie.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${pkgs.udiskie}/bin/udiskie --no-automount --tray";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
