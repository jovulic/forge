{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.restic;
in
with lib;
{
  options = {
    forge.system.restic = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable restic configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.restic
    ];
  };
}
