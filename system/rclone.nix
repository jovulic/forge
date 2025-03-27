{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.rclone;
in
with lib;
{
  options = {
    forge.system.rclone = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable rclone configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.rclone
    ];
  };
}
