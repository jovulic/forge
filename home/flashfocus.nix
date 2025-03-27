{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.flashfocus;
in
with lib;
{
  options = {
    forge.home.flashfocus = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable flashfocus configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      flashfocus = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Flash border when changing focus with flashfocus.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${pkgs.flashfocus}/bin/flashfocus";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
