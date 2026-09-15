{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.kanshi;
in
with lib;
{
  options = {
    forge.home.kanshi = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable kanshi configuration.";
      };
      configPath = mkOption {
        type = types.nullOr types.path;
        default = null;
        description = "Path to the kanshi config file.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      ".config/kanshi/config" = mkIf (cfg.configPath != null) {
        source = cfg.configPath;
      };
    };

    systemd.user.services.kanshi = {
      Unit = {
        Description = "Dynamic output configuration";
        Documentation = "man:kanshi(1)";
        PartOf = "sway-session.target";
        Requires = "sway-session.target";
        After = "sway-session.target";
      };
      Service = {
        Type = "simple";
        ExecStart = "${pkgs.kanshi}/bin/kanshi";
        Restart = "always";
      };
      Install = {
        WantedBy = [ "sway-session.target" ];
      };
    };
  };
}
