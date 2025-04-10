{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.waybar;
in
with lib;
{
  options = {
    forge.home.waybar = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable waybar configuration.";
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
      ".config/waybar/config" = {
        source = ./. + "/${cfg.name}-config";
      };
      ".config/waybar/style.css" = {
        source = ./. + "/${cfg.name}-style.css";
      };
      ".config/waybar/custom/custom-cpu.sh" = {
        source = ./custom-cpu.sh;
        executable = true;
      };
      ".config/waybar/custom/custom-gpu.sh" = {
        source = ./custom-gpu.sh;
        executable = true;
      };
    };

    systemd.user.services = {
      waybar = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Waybar as systemd service.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${pkgs.waybar}/bin/waybar";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
