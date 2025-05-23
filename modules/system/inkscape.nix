{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.inkscape;
in
with lib;
{
  options = {
    forge.system.inkscape = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable inkscape configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.inkscape
    ];
  };
}
