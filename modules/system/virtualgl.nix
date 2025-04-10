{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.virtualgl;
in
with lib;
{
  options = {
    forge.system.virtualgl = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable virtualgl configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.virtualgl
      pkgs.virtualglLib
    ];
  };
}
