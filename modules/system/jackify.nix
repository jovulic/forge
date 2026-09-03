{
  config,
  lib,
  pkgs,
  mypkgs,
  ...
}:
let
  cfg = config.forge.system.jackify;
in
with lib;
{
  options = {
    forge.system.jackify = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable jackify configuration.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      mypkgs.jackify
      (pkgs.makeDesktopItem {
        name = "jackify";
        desktopName = "Jackify";
        comment = "Linux-native Wabbajack modlist installer";
        exec = "jackify %u";
        icon = "com.jackify.app";
        categories = [
          "Game"
          "Utility"
        ];
        terminal = true;
        mimeTypes = [ "x-scheme-handler/jackify" ];
      })
    ];

    # Jackify requires Steam, Protontricks, and compatibility tools (like GE-Proton)
    # which are managed and configured by the Steam system module.
    forge.system.steam.enable = mkDefault true;
  };
}
