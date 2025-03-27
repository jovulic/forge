{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.font;
in
with lib;
{
  options = {
    forge.system.font = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable font configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    fonts = {
      packages =  [
        (pkgs.nerdfonts.override {
          fonts = [
            "JetBrainsMono"
            "Noto"
          ];
        })
      ];
      fontDir.enable = true;
      fontconfig = {
        enable = true;
        # How to find font family names.
        #
        # $ cd /nix/var/nix/profiles/system/sw/share/X11/fonts
        # $ fc-query DejaVuSans.ttf | grep '^\s\+family:' | cut -d'"' -f2
        #
        # source: https://nixos.wiki/wiki/Fonts#What_font_names_can_be_used_in_fonts.fontconfig.defaultFonts.monospace.3F
        defaultFonts = {
          serif = [ "NotoSerif Nerd Font" ]; # fc-match serif
          sansSerif = [ "NotoSans Nerd Font" ]; # fc-match sans
          monospace = [ "JetBrainsMono Nerd Font Mono" ]; # fc-match mono
        };
      };
    };
  };
}
