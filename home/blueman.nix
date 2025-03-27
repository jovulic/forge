{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.blueman;
in
with lib;
{
  options = {
    forge.home.blueman = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable blueman configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services.blueman-applet = {
      Unit = {
        Description = "Blueman applet";
      };
      Install = {
        WantedBy = [ "sway-session.target" ];
      };
      Service = {
        ExecStart = "${pkgs.blueman}/bin/blueman-applet";
      };
    };
  };
}
