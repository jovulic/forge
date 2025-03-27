{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.systemd;
in
with lib;
{
  options = {
    forge.home.systemd = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable systemd configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.packages = [
      pkgs.sd-switch
    ];

    # I believe this means home-manager will restart services as necessary now.
    systemd.user.startServices = "sd-switch";
  };
}
