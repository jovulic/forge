{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.firefox;
in
with lib;
{
  options = {
    forge.system.firefox = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable firefox configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.firefox-wayland
    ];
  };
}
