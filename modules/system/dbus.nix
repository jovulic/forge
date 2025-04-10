{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.dbus;
in
with lib;
{
  options = {
    forge.system.dbus = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable dbus configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    services.dbus = {
      enable = true;
    };
  };
}
