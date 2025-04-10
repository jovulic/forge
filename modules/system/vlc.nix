{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.vlc;
in
with lib;
{
  options = {
    forge.system.vlc = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable vlc configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.vlc
    ];
  };
}
