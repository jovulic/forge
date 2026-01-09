{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.kanata;
in
with lib;
{
  options = {
    forge.system.kanata = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kanata configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.kanata
    ];
  };
}
