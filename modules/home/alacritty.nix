{
  config,
  lib,
  options,
  ...
}:
let
  cfg = config.forge.home.alacritty;
in
with lib;
{
  options = {
    forge.home.alacritty = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable alacritty configuration.";
      };
      theme = options.programs.alacritty.theme;
      settings = options.programs.alacritty.settings;
    };
  };
  config = mkIf cfg.enable {
    programs.alacritty = recursiveUpdate {
      theme = "papercolor_dark";
      settings = {
        font = {
          normal = {
            family = "monospace";
          };
          size = 12;
        };
      }; # man 5 alacritty
    } cfg;
  };
}
