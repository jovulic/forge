#!/usr/bin/env bash

# If already recording, show toggle menu.
if pgrep -x "wf-recorder" >/dev/null; then
    if ! ACTION=$(printf "stop\ncancel\n" | bemenu -l 2 -i -p "Recording active:") || [ -z "$ACTION" ]; then
        exit 0
    fi
    case "$ACTION" in
    "stop")
        touch /tmp/screengrab-stop
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

# Clear any stale flags before starting.
rm -f /tmp/screengrab-cancel /tmp/screengrab-stop

VIDEO_DIR="${HOME}/videos"
mkdir -p "$VIDEO_DIR"

if ! TARGET=$(printf "area\nscreen\n" | bemenu -l 2 -i -p "Select capture target:") || [ -z "$TARGET" ]; then
    exit 0
fi

case "$TARGET" in
"area")
    if ! GEOM=$(slurp) || [ -z "$GEOM" ]; then
        exit 0
    fi
    FILENAME="${VIDEO_DIR}/screengrab-$(date +"%Y-%m-%d-%H-%M-%S").mp4"
    wf-recorder -g "$GEOM" -a -f "$FILENAME" >/dev/null 2>&1 &
    REC_PID=$!
    notify-send -t 3000 "Screengrab" "Started recording area."
    ;;

"screen")
    if ! GEOM=$(slurp -o) || [ -z "$GEOM" ]; then
        exit 0
    fi
    FILENAME="${VIDEO_DIR}/screengrab-$(date +"%Y-%m-%d-%H-%M-%S").mp4"
    wf-recorder -g "$GEOM" -a -f "$FILENAME" >/dev/null 2>&1 &
    REC_PID=$!
    notify-send -t 3000 "Screengrab" "Started recording screen."
    ;;
esac

# Spawn swaynag interactive bar and the auto-cleanup watcher.
if [ -n "$REC_PID" ]; then
    # Display swaynag bar at the top with Stop button (X button acts as
    # Cancel).
    swaynag -t warning -m "Recording active..." \
        -B "Stop" "touch /tmp/screengrab-stop && killall -s SIGINT wf-recorder" >/dev/null 2>&1 &
    NAG_PID=$!

    # Watcher background process.
    (
        # Wait until either wf-recorder (REC_PID) or swaynag (NAG_PID) exits.
        while kill -0 "$REC_PID" 2>/dev/null && kill -0 "$NAG_PID" 2>/dev/null; do
            sleep 0.5
        done

        # Give a split second for signals and file writes to settle.
        sleep 0.2

        # CASE 1: Stop flag is set (clicked Stop button or selected stop in
        # toggle).
        if [ -f /tmp/screengrab-stop ]; then
            kill "$NAG_PID" 2>/dev/null
            rm -f /tmp/screengrab-stop
            notify-send -t 4000 "Screengrab" "Recording saved: $(basename "$FILENAME")"

        # CASE 2: Cancel flag is set (selected cancel in toggle).
        elif [ -f /tmp/screengrab-cancel ]; then
            kill "$NAG_PID" 2>/dev/null
            killall -s SIGINT wf-recorder 2>/dev/null
            sleep 0.5
            rm -f "$FILENAME"
            rm -f /tmp/screengrab-cancel
            notify-send -t 3000 "Screengrab" "Recording cancelled."

        # CASE 3: No flags set, but swaynag exited first (user clicked 'X'
        # close button).
        elif ! kill -0 "$NAG_PID" 2>/dev/null && kill -0 "$REC_PID" 2>/dev/null; then
            killall -s SIGINT wf-recorder 2>/dev/null
            sleep 0.5
            rm -f "$FILENAME"
            notify-send -t 3000 "Screengrab" "Recording cancelled."

        # CASE 4: No flags set, but wf-recorder exited first (e.g. process
        # died/crashed)
        else
            kill "$NAG_PID" 2>/dev/null
            notify-send -t 4000 "Screengrab" "Recording saved: $(basename "$FILENAME")"
        fi
    ) &
    disown
fi
