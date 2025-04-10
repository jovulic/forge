{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.lutris;
in
with lib;
{
  options = {
    forge.system.lutris = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable lutris configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.lutris
      (pkgs.wine.override { wineBuild = "wine64"; })
      pkgs.winetricks
      pkgs.wineWowPackages.stable
      pkgs.wineWowPackages.waylandFull
      pkgs.wineWowPackages.fonts
      pkgs.mono
    ];
  };
}
