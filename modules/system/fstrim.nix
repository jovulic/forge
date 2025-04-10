{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.fstrim;
in
with lib;
{
  options = {
    forge.system.fstrim = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable fstrim configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    services.fstrim = {
      enable = true;
    };
  };
}
