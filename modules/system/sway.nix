{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.sway;
in
with lib;
{
  options = {
    forge.system.sway = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable sway configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.wl-clipboard
      pkgs.bemenu # dmenu
      pkgs.jq # samedir
      pkgs.wtype # samedir native window hooks
      pkgs.brightnessctl # light control (brightnessctl)
      pkgs.pulseaudio # audo control (pactl)
      pkgs.wev # debug inputs
      (pkgs.writeShellScriptBin "samedir" ''
        # Get the focused window's PID and application class/app_id from Sway
        focused_info=$(swaymsg -t get_tree | jq -r '.. | select(.type?) | select(.focused==true) | "\(.pid):\(.app_id // .window_properties.class)"')
        pid=$(echo "$focused_info" | cut -d':' -f1)
        app_id=$(echo "$focused_info" | cut -d':' -f2)

        # If the focused window is Ghostty (single-instance daemon mode), we cannot
        # reliably look up the child shell PID because all windows share a parent daemon PID.
        # Instead, we trigger Ghostty's native "new window" shortcut via Wayland keyboard simulation.
        # Ghostty natively inherits the directory of the focused tab/window.
        if [ "$app_id" = "com.mitchellh.ghostty" ]; then
          exec wtype -M ctrl -M shift n -m shift -m ctrl
        fi

        # Fallback to standard process tree traversal for other terminal emulators (e.g. foot, alacritty)
        ppid=$(pgrep --newest --parent ''${pid})
        CWD="$(readlink /proc/''${ppid}/cwd || echo $HOME)"

        if [ "$TERMINAL" = "ghostty" ]; then
          exec ghostty +new-window --working-directory="$CWD"
        elif [ "$TERMINAL" = "alacritty" ]; then
          exec alacritty --working-directory "$CWD"
        elif [ "$TERMINAL" = "foot" ]; then
          exec foot --working-directory="$CWD"
        else
          cd "$CWD"
          exec "$TERMINAL"
        fi
      '')
      (pkgs.writeShellScriptBin "prompt" ''
        # A binary prompt script.
        # Gives a prompt labeled with $1 to perform command $2.
        # For example:
        # `./prompt "Do you want to shutdown?" "shutdown -h now"`

        [ "$(printf "No\\nYes" | bemenu -f -i -p "$1")" = "Yes" ] && $2
      '')
      pkgs.wdisplays
      pkgs.nwg-displays
    ];
    programs.sway = {
      enable = true;
      extraSessionCommands = ''
        export EDITOR=nvim
        export TERMINAL=${config.forge.system.terminal.name}
        export BROWSER=google-chrome-stable
        export READER=zathura
        export FILE=n
        export SSH_AUTH_SOCK=$(gpgconf --list-dirs agent-ssh-socket)
        export BEMENU_OPTS="--tb '#6272a4'\
          --tf '#f8f8f2'\
          --fb '#282a36'\
          --ff '#f8f8f2'\
          --nb '#282a36'\
          --nf '#6272a4'\
          --hb '#44475a'\
          --hf '#50fa7b'\
          --sb '#44475a'\
          --sf '#50fa7b'\
          --scb '#282a36'\
          --scf '#ff79c6'"
      '';
    };
  };
}
