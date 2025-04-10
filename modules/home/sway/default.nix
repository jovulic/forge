{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.sway;
in
with lib;
{
  options = {
    forge.home.sway = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable sway configuration.";
      };
      name = mkOption {
        type = types.str;
        example = "licious";
        description = "Name of the machine.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      ".config/sway/config" = {
        source = ./. + "/${cfg.name}-config";
      };
    };

    systemd.user.targets.sway-session = {
      Unit = {
        Description = "sway compositor session";
        Documentation = [ "man:systemd.special(7)" ];
        BindsTo = [ "graphical-session.target" ];
        Wants = [ "graphical-session-pre.target" ];
        After = [ "graphical-session-pre.target" ];
      };
    };

    systemd.user.targets.tray = {
      Unit = {
        Description = "System Tray";
        Requires = [ "graphical-session-pre.target" ];
      };
    };

    systemd.user.services = {
      idle = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Idle manager using swayidle.";
          Documentation = "man:swayidle(1)";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = ''
            ${pkgs.swayidle}/bin/swayidle -w -d \
            timeout 900 '${pkgs.swaylock}/bin/swaylock -f -c 000000' \
            timeout 3600 '${pkgs.sway}/bin/swaymsg "output * dpms off"' \
              resume '${pkgs.sway}/bin/swaymsg "output * dpms on"' \
            before-sleep '${pkgs.swaylock}/bin/swaylock -f -c 000000'
          '';
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
