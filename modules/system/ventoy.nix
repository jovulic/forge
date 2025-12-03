{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.ventoy;
in
with lib;
{
  options = {
    forge.system.ventoy = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable ventoy configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.ventoy
    ];
  };
}
