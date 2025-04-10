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
    environment.systemPackages =  [
      pkgs.wl-clipboard
      pkgs.bemenu # dmenu
      pkgs.jq # samedir
      pkgs.light # light control (light)
      pkgs.pulseaudio # audo control (pactl)
      pkgs.wev # debug inputs
      (pkgs.writeShellScriptBin "samedir" ''
        pid=$(swaymsg -t get_tree | jq '.. | select(.type?) | select(.type=="con") | select(.focused==true).pid')
        ppid=$(pgrep --newest --parent ''${pid})
        cd "$(readlink /proc/''${ppid}/cwd || echo $HOME)"
        "$TERMINAL"
      '')
      (pkgs.writeShellScriptBin "prompt" ''
        # A binary prompt script.
        # Gives a prompt labeled with $1 to perform command $2.
        # For example:
        # `./prompt "Do you want to shutdown?" "shutdown -h now"`

        [ "$(printf "No\\nYes" | bemenu -f -i -p "$1")" = "Yes" ] && $2
      '')
      pkgs.wdisplays
    ];
    programs.sway = {
      enable = true;
      extraSessionCommands = ''
        export EDITOR=nvim
        export TERMINAL=foot
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
