{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.location;
in
with lib;
{
  options = {
    forge.system.location = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable location configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    services.geoclue2 = {
      enable = true;
    };
  };
}
