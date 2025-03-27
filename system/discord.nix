{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.discord;
in
with lib;
{
  options = {
    forge.system.discord = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable discord configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.discord
    ];
  };
}
