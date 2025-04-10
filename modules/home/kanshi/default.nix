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
        default = true;
        description = "Enable kanshi configuration.";
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
      ".config/kanshi/config" = {
        source = ./. + "/${cfg.name}-config";
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
