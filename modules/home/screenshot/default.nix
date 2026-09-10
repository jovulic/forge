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
    programs.satty = {
      enable = true;
      settings = {
        general = {
          fullscreen = "current-screen";
          resize = { mode = "smart"; };
          floating-hack = true;
          early-exit = true;
          initial-tool = "crop";
          copy-command = "${pkgs.wl-clipboard}/bin/wl-copy";
          annotation-size-factor = 2.0;
          output-filename = "${config.home.homeDirectory}/pictures/satty-%Y-%m-%d_%H:%M:%S.png";
          save-after-copy = false;
          default-hide-toolbars = false;
        };
      };
    };
  };
}
