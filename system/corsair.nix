{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.corsair;
in
with lib;
{
  options = {
    forge.system.corsair = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable corsair configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    hardware = {
      ckb-next = {
        enable = true;
      };
    };
  };
}
