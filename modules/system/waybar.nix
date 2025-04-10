{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.waybar;
in
with lib;
{
  options = {
    forge.system.waybar = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable waybar configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.waybar
    ];
  };
}
