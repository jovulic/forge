{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.gammastep;
in
with lib;
{
  options = {
    forge.system.gammastep = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gammastep configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.gammastep
    ];
  };
}
