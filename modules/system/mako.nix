{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.mako;
in
with lib;
{
  options = {
    forge.system.mako = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable mako configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.mako
    ];
  };
}
