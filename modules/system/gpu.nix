{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.gpu;
in
with lib;
{
  options = {
    forge.system.gpu = {
      vendor = mkOption {
        type = types.enum [ "amd" "intel" "nvidia" "none" ];
        default = "none";
        description = "The GPU vendor for this system. Used to enable specific drivers and tools.";
      };
    };
  };
}
