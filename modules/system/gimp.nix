{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.gimp;
in
with lib;
{
  options = {
    forge.system.gimp = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gimp configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.gimp
    ];
  };
}
