{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.recorder;
in
with lib;
{
  options = {
    forge.system.recorder = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable recorder configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.slurp
      pkgs.wf-recorder
      pkgs.libnotify # provides notify-send
      (pkgs.writeShellScriptBin "recorder-start" ''
        case "$(printf "yes\\nno\\n" | bemenu -l 2 -i -p "Start recording?")" in
            "yes") notify-send -t 5000 "Started recording" && wf-recorder -g "$(slurp)" -a -f ''${HOME}/videos/recording-$(date +"%Y-%m-%d-%H-%M-%S.mp4") ;;
            "no") exit 0 ;;
        esac
      '')
      (pkgs.writeShellScriptBin "recorder-end" ''
        killall -s SIGINT wf-recorder

        notify-send -t 5000 "Stopped recording"
      '')
    ];
  };
}
