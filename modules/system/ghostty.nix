{ config
, lib
, pkgs
, ...
}:
let
  cfg = config.forge.system.ghostty;
in
with lib;
{
  options = {
    forge.system.ghostty = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ghostty terminal configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.ghostty
    ];
  };
}
