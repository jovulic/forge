{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.mpv;
in
with lib;
{
  options = {
    forge.system.mpv = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable mpv configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.mpv
    ];
  };
}
