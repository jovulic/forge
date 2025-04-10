{
  config,
  lib,
  mypkgs,
  ...
}:
let
  cfg = config.forge.home.plover;
in
with lib;
{
  options = {
    forge.home.plover = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable plover configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      plover = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "Open stenography software.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${mypkgs.plover}/bin/plover";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
