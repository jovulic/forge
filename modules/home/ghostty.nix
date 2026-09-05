{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.forge.home.ghostty;
in
with lib;
{
  options = {
    forge.home.ghostty = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ghostty configuration.";
      };
      settings = options.programs.ghostty.settings;
    };
  };

  config = mkIf cfg.enable {
    programs.ghostty = {
      enable = true;
      systemd.enable = true;
      settings = recursiveUpdate {
        font-family = "monospace";
        font-size = 13;
        scrollback-limit = 50000000; # 50MB

        # Wayland integrations
        window-decoration = false; # no titlebar, clean tiling

        # Daemon/window lifecycle settings
        window-inherit-working-directory = false;
        quit-after-last-window-closed = true;
        quit-after-last-window-closed-delay = "5m";

        # Catppuccin Mocha Sapphire Theme
        background = "1e1e2e";
        foreground = "cdd6f4";
        cursor-color = "f5e0dc";
        cursor-text = "74c7ec";
        selection-background = "585b70";
        selection-foreground = "cdd6f4";

        palette = [
          "0=#45475a"
          "1=#f38ba8"
          "2=#a6e3a1"
          "3=#f9e2af"
          "4=#89b4fa"
          "5=#cba6f7"
          "6=#94e2d5"
          "7=#bac2de"
          "8=#585b70"
          "9=#f38ba8"
          "10=#a6e3a1"
          "11=#f9e2af"
          "12=#89b4fa"
          "13=#cba6f7"
          "14=#94e2d5"
          "15=#a6adc8"
        ];
      } cfg.settings;
    };
  };
}
