{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.gtk;
in
with lib;
{
  options = {
    forge.home.gtk = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable GTK and Icon theme styling.";
      };
    };
  };

  config = mkIf cfg.enable {
    home.pointerCursor = {
      gtk.enable = true;
      x11.enable = true;
      name = "catppuccin-mocha-sapphire-cursors";
      size = 24;
      package = pkgs.catppuccin-cursors.mochaSapphire;
    };

    gtk = {
      enable = true;
      theme = {
        name = "catppuccin-mocha-sapphire-standard";
        package = pkgs.catppuccin-gtk.override {
          accents = [ "sapphire" ];
          size = "standard";
          variant = "mocha";
        };
      };
      iconTheme = {
        name = "Papirus-Dark";
        package = pkgs.papirus-icon-theme;
      };
      font = {
        name = "Noto Sans";
        size = 10;
        package = pkgs.noto-fonts;
      };
      gtk4.theme = null;
    };

    dconf.settings = {
      "org/gnome/desktop/interface" = {
        color-scheme = "prefer-dark";
      };
    };
  };
}
