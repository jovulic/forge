{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.xbox;
in
with lib;
{
  options = {
    forge.system.xbox = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable xbox configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    hardware = {
      xpadneo = {
        enable = true;
      };
    };
  };
}
