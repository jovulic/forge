{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.heroic;
in
with lib;
{
  options = {
    forge.system.heroic = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable heroic configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.heroic
    ];
  };
}
