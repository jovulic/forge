{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.forge.home.foot;
in
with lib;
{
  options = {
    forge.home.foot = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable foot configuration.";
      };
      theme = mkOption {
        type = types.enum [ "catppuccin-mocha-sapphire" "paper-color-dark" ];
        default = "catppuccin-mocha-sapphire";
        description = "Color theme for foot terminal.";
      };
      settings = options.programs.foot.settings;
    };
  };
  config = mkIf cfg.enable {
    programs.foot = {
      enable = true;
      settings = recursiveUpdate {
        main = {
          font = "monospace:size=12";
        };
        scrollback = {
          lines = 100000;
        };
        colors-dark = if cfg.theme == "catppuccin-mocha-sapphire" then {
          # Catppuccin Mocha Sapphire
          background = "1e1e2e";
          foreground = "cdd6f4";
          cursor = "f5e0dc 74c7ec"; # rosewater on sapphire
          selection-foreground = "cdd6f4";
          selection-background = "585b70";
          regular0 = "45475a"; # surface1
          regular1 = "f38ba8"; # red
          regular2 = "a6e3a1"; # green
          regular3 = "f9e2af"; # yellow
          regular4 = "89b4fa"; # blue
          regular5 = "cba6f7"; # mauve
          regular6 = "94e2d5"; # teal
          regular7 = "bac2de"; # subtext1
          bright0 = "585b70";  # surface2
          bright1 = "f38ba8";
          bright2 = "a6e3a1";
          bright3 = "f9e2af";
          bright4 = "89b4fa";
          bright5 = "cba6f7";
          bright6 = "94e2d5";
          bright7 = "a6adc8";  # subtext0
        } else {
          # https://codeberg.org/dnkl/foot/src/branch/master/themes/paper-color-dark
          cursor = "1c1c1c eeeeee";
          background = "1c1c1c";
          foreground = "eeeeee";
          regular0 = "1c1c1c"; # black
          regular1 = "af005f"; # red
          regular2 = "5faf00"; # green
          regular3 = "d7af5f"; # yellow
          regular4 = "5fafd7"; # blue
          regular5 = "808080"; # magenta
          regular6 = "d7875f"; # cyan
          regular7 = "d0d0d0"; # white
          bright0 = "bcbcbc"; # bright black
          bright1 = "5faf5f"; # bright red
          bright2 = "afd700"; # bright green
          bright3 = "af87d7"; # bright yellow
          bright4 = "ffaf00"; # bright blue
          bright5 = "ff5faf"; # bright magenta
          bright6 = "00afaf"; # bright cyan
          bright7 = "5f8787"; # bright white
          # selection-foreground=1c1c1c
          # selection-background=af87d7
        };
      } cfg.settings;
    };
  };
}
