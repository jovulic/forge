{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.sxiv;
in
with lib;
{
  options = {
    forge.system.sxiv = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable sxiv configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.sxiv
    ];
  };
}
