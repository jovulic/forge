{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.foot;
  iniformat = pkgs.formats.ini { };
in
with lib;
{
  options = {
    forge.home.foot = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable foot configuration.";
      };
      settings = mkOption {
        type = iniformat.type;
        default = {
          main = {
            font = "monospace:size=11";
          };
          scrollback = {
            lines = 100000;
          };
          # https://codeberg.org/dnkl/foot/src/branch/master/themes/paper-color-dark
          cursor = {
            color = "1c1c1c eeeeee";
          };
          colors = {
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
        }; # https://codeberg.org/dnkl/foot/raw/branch/master/foot.ini
        description = ''
          Configuration written to
          <filename>$XDG_CONFIG_HOME/foot/foot.ini</filename>. See <link
          xlink:href="https://codeberg.org/dnkl/foot/src/branch/master/foot.ini"/>
          for a list of available options.
        '';
        example = literalExpression ''
          {
            main = {
              term = "xterm-256color";
              font = "Fira Code:size=11";
              dpi-aware = "yes";
            };
            mouse = {
              hide-when-typing = "yes";
            };
          }
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    xdg.configFile."foot/foot.ini" = {
      source = iniformat.generate "foot.ini" cfg.settings;
    };
  };
}
