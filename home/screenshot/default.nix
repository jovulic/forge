{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.screenshot;
in
with lib;
{
  options = {
    forge.home.screenshot = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable screenshot configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      ".config/swappy/config" = {
        source = pkgs.writeText "config" ''
          [Default]
          save_dir=$HOME/pictures
          save_filename_format=swapshot-%Y-%m-%d-%H-%M-%S.png
          show_panel=false
          line_size=5
          text_size=20
          text_font=sans-serif
          paint_mode=brush
          early_exit=false
          fill_shape=false
        '';
      };
    };
  };
}
