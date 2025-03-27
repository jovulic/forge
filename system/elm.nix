{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.elm;
in
with lib;
{
  options = {
    forge.system.elm = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable elm configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.elmPackages.elm # $ elm init
      pkgs.elmPackages.elm-format
    ];
  };
}
