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
        pkgs.sway-contrib.grimshot
        pkgs.swappy
        (pkgs.writeShellScriptBin "dscreenshot" ''
          case "$(printf "clip\\nfile\\nswap\\n" | bemenu -l 3 -i -p "Select action.")" in
              "clip") grimshot copy area ;;
              "file") grimshot save area ''${HOME}/pictures/screenshot-$(date +"%Y-%m-%d-%H-%M-%S.png") ;;
              "swap") grim -g "$(slurp)" - | swappy -f - ;;
          esac
        '')
      ];
  };
}
