{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.mako;
in
with lib;
{
  options = {
    forge.home.mako = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable mako configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      ".config/mako/config" = {
        onChange = ''
          ${pkgs.mako}/bin/makoctl reload || true
        '';
        source = ./config;
      };
    };

    systemd.user.services = {
      mako = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Notification daemon with mako.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${pkgs.mako}/bin/mako";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
