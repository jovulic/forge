{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.blueman;
in
with lib;
{
  options = {
    forge.system.blueman = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable blueman configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    services.blueman = {
      enable = true;
    };
  };
}
