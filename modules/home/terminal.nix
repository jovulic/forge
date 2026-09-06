{ config
, lib
, ...
}:
let
  cfg = config.forge.home.terminal;
in
with lib;
{
  options = {
    forge.home.terminal = {
      name = mkOption {
        type = types.enum [ "ghostty" "foot" "alacritty" ];
        default = "ghostty";
        description = "The default terminal emulator for the user session.";
      };
    };
  };

  config = {
    xdg.terminal-exec = {
      enable = true;
      settings = {
        default = [
          (if cfg.name == "ghostty" then "ghostty-new-window.desktop" else "${cfg.name}.desktop")
        ];
      };
    };

    xdg.desktopEntries = mkIf (cfg.name == "ghostty") {
      "ghostty-new-window" = {
        name = "Ghostty (new window)";
        exec = "ghostty +new-window";
        type = "Application";
        categories = [ "TerminalEmulator" ];
        settings = {
          "X-TerminalArgExec" = "-e";
        };
      };
    };
  };
}
