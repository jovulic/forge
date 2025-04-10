{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.matrix;
in
with lib;
{
  options = {
    forge.system.matrix = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable matrix configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.element-desktop
    ];
  };
}
