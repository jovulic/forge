{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.light;
in
with lib;
{
  options = {
    forge.system.light = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable light configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.light = {
      enable = true;
    };
  };
}
