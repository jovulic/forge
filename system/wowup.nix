{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.wowup;
in
with lib;
{
  options = {
    forge.system.wowup = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable wowup configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      (pkgs.appimageTools.wrapType2 {
        name = "wowup";
        src = pkgs.fetchurl {
          url = "https://github.com/WowUp/WowUp/releases/download/v2.11.0/WowUp-2.11.0.AppImage";
          hash = "sha256-Q1lrX87nQMu172D0QlCoFXbYr5WwXXUjPipL5tGn02k=";
        };
      })
    ];
  };
}
