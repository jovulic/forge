{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.alacritty;
in
with lib;
{
  options = {
    forge.system.alacritty = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable alacritty configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.alacritty
    ];
  };
}
