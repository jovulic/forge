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
        default = pkgs.stdenv.isLinux;
        description = "Enable waybar configuration.";
      };
      configPath = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to the waybar config file.";
      };
      stylePath = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to the waybar style.css file.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      ".config/waybar/config" = mkIf (cfg.configPath != null) {
        source = cfg.configPath;
      };
      ".config/waybar/style.css" = mkIf (cfg.stylePath != null) {
        source = cfg.stylePath;
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
