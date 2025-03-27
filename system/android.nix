{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.android;
in
with lib;
{
  options = {
    forge.system.android = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable android configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.adb = {
      enable = true;
    };

    environment.systemPackages = [
      pkgs.adbfs-rootless
    ];
  };
}
