{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.nemo;
in
with lib;
{
  options = {
    forge.system.nemo = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable nemo configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.nemo
    ];
  };
}
