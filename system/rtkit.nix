{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.rtkit;
in
with lib;
{
  options = {
    forge.system.rtkit = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable rtkit configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # the RealtimeKit system service, which hands out realtime scheduling
    # priority to user processes on demand. For example, the PulseAudio server
    # uses this to acquire realtime priority.
    security.rtkit = {
      enable = true;
    };
  };
}
