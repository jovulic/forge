{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.screengrab;
in
with lib;
{
  options = {
    forge.system.screengrab = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable screen grab (video recording) configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.slurp
      pkgs.wf-recorder
      pkgs.libnotify
      (pkgs.writeShellScriptBin "dscreengrab" ''
        # If already recording, show toggle menu
        if pgrep -x "wf-recorder" >/dev/null; then
            ACTION=$(printf "stop\\ncancel\\n" | bemenu -l 2 -i -p "Recording active:")
            case "$ACTION" in
                "stop")
                    killall -s SIGINT wf-recorder
                    exit 0
                    ;;
                "cancel")
                    touch /tmp/screengrab-cancel
                    killall -s SIGINT wf-recorder
                    exit 0
                    ;;
                *)
                    exit 0
                    ;;
            esac
        fi

        # Clear any stale cancel flags before starting
        rm -f /tmp/screengrab-cancel

        VIDEO_DIR="''${HOME}/videos"
        mkdir -p "$VIDEO_DIR"

        TARGET=$(printf "area\\nscreen\\ncancel\\n" | bemenu -l 3 -i -p "Select capture target:")

        case "$TARGET" in
            "area")
                GEOM=$(slurp)
                if [ $? -ne 0 ] || [ -z "$GEOM" ]; then
                    exit 0
                fi
                
                ACTION=$(printf "no audio\\nwith audio\\ncancel\\n" | bemenu -l 3 -i -p "Start recording?")
                case "$ACTION" in
                    "no audio")
                        FILENAME="''${VIDEO_DIR}/screengrab-$(date +"%Y-%m-%d-%H-%M-%S").mp4"
                        wf-recorder -g "$GEOM" -f "$FILENAME" >/dev/null 2>&1 &
                        REC_PID=$!
                        notify-send -t 3000 "Screengrab" "Started recording area."
                        ;;
                    "with audio")
                        FILENAME="''${VIDEO_DIR}/screengrab-$(date +"%Y-%m-%d-%H-%M-%S").mp4"
                        wf-recorder -g "$GEOM" -a -f "$FILENAME" >/dev/null 2>&1 &
                        REC_PID=$!
                        notify-send -t 3000 "Screengrab" "Started recording area with audio."
                        ;;
                    *)
                        exit 0
                        ;;
                esac
                ;;
                
            "screen")
                ACTION=$(printf "no audio\\nwith audio\\ncancel\\n" | bemenu -l 3 -i -p "Start recording?")
                case "$ACTION" in
                    "no audio")
                        FILENAME="''${VIDEO_DIR}/screengrab-$(date +"%Y-%m-%d-%H-%M-%S").mp4"
                        wf-recorder -f "$FILENAME" >/dev/null 2>&1 &
                        REC_PID=$!
                        notify-send -t 3000 "Screengrab" "Started recording screen."
                        ;;
                    "with audio")
                        FILENAME="''${VIDEO_DIR}/screengrab-$(date +"%Y-%m-%d-%H-%M-%S").mp4"
                        wf-recorder -a -f "$FILENAME" >/dev/null 2>&1 &
                        REC_PID=$!
                        notify-send -t 3000 "Screengrab" "Started recording screen with audio."
                        ;;
                    *)
                        exit 0
                        ;;
                esac
                ;;
            *)
                exit 0
                ;;
        esac

        # Spawn swaynag interactive bar and the auto-cleanup watcher
        if [ -n "$REC_PID" ]; then
            # Display swaynag bar at the top with Stop and Cancel buttons
            swaynag -t info -m "Recording active..." \
                -B "Stop" "killall -s SIGINT wf-recorder" \
                -B "Cancel" "touch /tmp/screengrab-cancel && killall -s SIGINT wf-recorder" >/dev/null 2>&1 &
            NAG_PID=$!

            # Watcher background process
            (
                while kill -0 "$REC_PID" 2>/dev/null; do
                    sleep 0.5
                done
                
                # If swaynag is still running, kill it
                if kill -0 "$NAG_PID" 2>/dev/null; then
                    kill "$NAG_PID" 2>/dev/null
                fi

                # Handle cancel or stop finalization
                if [ -f /tmp/screengrab-cancel ]; then
                    rm -f "$FILENAME"
                    rm -f /tmp/screengrab-cancel
                    notify-send -t 3000 "Screengrab" "Recording cancelled."
                else
                    notify-send -t 3000 "Screengrab" "Recording saved."
                fi
            ) &
            disown
        fi
      '')
    ];
  };
}
