#!/usr/bin/env bash

# TCP Port that Kanata is listening on.
KANATA_PORT=10000

# Ensure SWAYSOCK is set.
if [ -z "${SWAYSOCK:-}" ]; then
    echo "Error: SWAYSOCK is not set. Exiting..." >&2
    exit 1
fi

# ---------------------------------------------------------
# DISCOVER MODE
# ---------------------------------------------------------
if [[ "${1:-}" == "--discover" ]]; then
    echo "=========================================================="
    echo " Kanata Automator - DISCOVER MODE"
    echo "=========================================================="
    echo "Focus on different windows to see their app_id or class."
    echo "Press Ctrl+C to exit."
    echo "Using SWAYSOCK: $SWAYSOCK"
    echo "----------------------------------------------------------"

    swaymsg -t subscribe -m '[ "window" ]' | jq --unbuffered -r '.container.app_id // .container.window_properties.class' | while read -r app_id; do
        if [ -n "$app_id" ] && [ "$app_id" != "null" ]; then
            echo "[$(date +'%H:%M:%S')] Focused App ID: $app_id"
        fi
    done
    exit 0
fi

# ---------------------------------------------------------
# DAEMON MODE
# ---------------------------------------------------------
echo "Starting Kanata Automator Daemon (SWAYSOCK: $SWAYSOCK)..."

# Track the active layer state to prevent redundant TCP calls.
CURRENT_LAYER=""

switch_layer() {
    local target_layer=$1

    if [ "$target_layer" == "$CURRENT_LAYER" ]; then
        return
    fi

    echo "Switching to layer: $target_layer (previous: ${CURRENT_LAYER:-none})"
    # Send JSON command to Kanata via TCP socket.
    printf '{"ChangeLayer":{"new":"%s"}}\n' "$target_layer" | nc -w1 127.0.0.1 $KANATA_PORT >/dev/null 2>&1 || echo "Warning: Kanata TCP server unreachable"

    CURRENT_LAYER="$target_layer"
}

# Ensure we start on the default layer.
switch_layer "default"

# Subscribe to Sway window focus events.
swaymsg -t subscribe -m '[ "window" ]' | jq --unbuffered -r '.container.app_id // .container.window_properties.class' | while read -r app_id; do

    # Ignore empty/null events.
    if [ -z "$app_id" ] || [ "$app_id" == "null" ]; then
        continue
    fi

    # Match the specific profile based on app id.
    if [[ "$app_id" =~ "steam_app_4032769339" ]]; then
        switch_layer "wow"
    elif [[ "$app_id" =~ "steam_app_1771300" ]]; then
        switch_layer "kcd2"
    else
        switch_layer "default"
    fi

done
