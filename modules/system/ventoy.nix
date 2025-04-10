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
        default = true;
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
