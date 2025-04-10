{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.forge.system.keyd;
in
with lib;
{
  options = {
    forge.system.keyd = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable keyd configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.keyd
    ];

    # Check that the keyd service is running with `systemctl status keyd`.
    # We can fetch the relevant device ids with `keyd monitor`.
    services.keyd = {
      enable = true;
    };
  };
}
