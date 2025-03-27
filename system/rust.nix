{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.rust;
in
with lib;
{
  options = {
    forge.system.rust = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable rust configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.rustc
      pkgs.cargo
    ];
  };
}
