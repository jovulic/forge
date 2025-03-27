{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.gparted;
in
with lib;
{
  options = {
    forge.system.gparted = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gparted configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.gparted
    ];
  };
}
