{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.kanshi;
in
with lib;
{
  options = {
    forge.system.kanshi = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kanshi configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.kanshi
    ];
  };
}
