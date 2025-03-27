{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.opentablet;
in
with lib;
{
  options = {
    forge.system.opentablet = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable opentablet configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    hardware.opentabletdriver = {
      enable = true;
    };
  };
}
