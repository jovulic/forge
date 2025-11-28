# NOTE: The module here is minimal as to setup Secure Boot you need to first
# run sbctl to then reference the lanzaboote nixos module and to apply it's
# configuration. A bit tricky and therefore we keep the automatic
# configuration minimal here.
{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.secureboot;
in
with lib;
{
  options = {
    forge.system.secureboot = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable secureboot configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.sbctl # Secure Boot key manager
    ];
  };
}
