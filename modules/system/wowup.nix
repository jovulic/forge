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
  config =
    let
      # Legacy package build for reference.
      # wowup = (
      #   pkgs.appimageTools.wrapType2 {
      #     pname = "wowup";
      #     version = "v2.11.0";
      #     src = pkgs.fetchurl {
      #       url = "https://github.com/WowUp/WowUp/releases/download/v2.11.0/WowUp-2.11.0.AppImage";
      #       hash = "sha256-Q1lrX87nQMu172D0QlCoFXbYr5WwXXUjPipL5tGn02k=";
      #     };
      #   }
      # );
    in
    mkIf cfg.enable {
      environment.systemPackages = [
        pkgs.wowup-cf
      ];
    };
}
