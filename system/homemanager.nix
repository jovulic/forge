{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.homemanager;
in
with lib;
{
  options = {
    forge.system.homemanager = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable homemanager configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.home-manager
    ];
  };
}
