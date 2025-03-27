{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.udiskie;
in
with lib;
{
  options = {
    forge.system.udiskie = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable udiskie configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.udiskie
    ];
  };
}
