{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.sensors;
in
with lib;
{
  options = {
    forge.system.sensors = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable sensors configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.lm_sensors
    ];
  };
}
