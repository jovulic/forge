{
  pkgs,
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.xpra;
in
with lib;
{
  options = {
    forge.system.xpra = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable xpra configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.xpra
    ];
    # example: xpra start ssh://scout@outpost.lan --start=firefox
  };
}
