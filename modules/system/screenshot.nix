{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.screenshot;
in
with lib;
{
  options = {
    forge.system.screenshot = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable screenshot configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =
      [
        pkgs.grim
        pkgs.slurp
        pkgs.sway-contrib.grimshot
        pkgs.satty
        pkgs.wl-clipboard
        (pkgs.writeShellScriptBin "dscreenshot" ''
          case "$(printf "copy screen\\nedit screen\\ncopy area\\nedit area\\n" | bemenu -l 4 -i -p "Select action:")" in
              "copy screen") sleep 0.2 && grim - | wl-copy ;;
              "edit screen") sleep 0.2 && grim - | satty --filename - --fullscreen ;;
              "copy area") grimshot copy area ;;
              "edit area") grim -g "$(slurp)" - | satty --filename - --fullscreen ;;
          esac
        '')
      ];
  };
}
