{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.valheim;
in
with lib;
{
  options = {
    forge.system.valheim = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable valheim configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.r2modman
    ];
  };
}
