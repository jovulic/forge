{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.imv;
in
with lib;
{
  options = {
    forge.system.imv = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable imv configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.imv
    ];
  };
}
