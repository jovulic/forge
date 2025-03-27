{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.xdg;
in
with lib;
{
  options = {
    forge.system.xdg = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable xdg configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    xdg = {
      # mime = {
      #   enable = true;
      #   defaultApplications = {
      #     "x-www-browser" = [ "google-chrome.desktop" ];
      #     "x-scheme-handler/http" = [ "google-chrome.desktop" ];
      #     "x-scheme-handler/https" = [ "google-chrome.desktop" ];
      #     "x-scheme-handler/about" = [ "google-chrome.desktop" ];
      #   };
      # };
      icons = {
        enable = true;
      };
      sounds = {
        enable = true;
      };
      portal = {
        # Might want to activate in order to allow screen sharing.
        # https://nixos.org/manual/nixos/stable/index.html#sec-wayland
        wlr.enable = true;
      };
      autostart = {
        enable = true;
      };
    };
  };
}
