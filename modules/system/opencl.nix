{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.opencl;
in
with lib;
{
  options = {
    forge.system.opencl = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable opencl configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.clinfo
    ];
  };
}
