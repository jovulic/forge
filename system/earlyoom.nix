{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.earlyoom;
in
with lib;
{
  options = {
    forge.system.earlyoom = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable earlyoom configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # Service that will start to kill processes once close to oom.
    services.earlyoom = {
      enable = true;
    };
  };
}
