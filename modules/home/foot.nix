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
        default = true;
        description = "Enable foot configuration.";
      };
      settings = options.programs.foot.settings;
    };
  };
  config = mkIf cfg.enable {
    programs.foot = recursiveUpdate {
      settings = {
        main = {
          font = "monospace:size=12";
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
      }; # man 5 foot.init
    } cfg;
  };
}
