{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.udisks2;
in
with lib;
{
  options = {
    forge.system.udisks2 = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable udisks2 configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    services.udisks2 = {
      enable = true;
    };
  };
}
