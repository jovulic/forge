{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.pdf;
in
with lib;
{
  options = {
    forge.system.pdf = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable pdf configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.pdftk
      pkgs.imagemagickBig
    ];
  };
}
