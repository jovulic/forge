{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.remote;
in
with lib;
{
  options = {
    forge.system.remote = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable remote configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.remmina
    ];
  };
}
