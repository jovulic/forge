{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.r2modman;
in
with lib;
{
  options = {
    forge.system.r2modman = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable r2modman configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.r2modman
    ];
  };
}
