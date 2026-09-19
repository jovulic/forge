{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.clipboard;
in
with lib;
{
  options = {
    forge.home.clipboard = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable clipboard configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      clipboard = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Clipboard using clipman and wl-clipboard.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${pkgs.wl-clipboard}/bin/wl-paste -t text --watch ${pkgs.clipman}/bin/clipman store --max-items=1000";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
