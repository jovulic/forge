{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.gpu;
in
with lib;
{
  options = {
    forge.home.gpu = {
      vendor = mkOption {
        type = types.enum [ "amd" "intel" "nvidia" "none" ];
        default = "none";
        description = "The GPU vendor for this home profile. Used to verify VR configurations.";
      };
    };
  };
}
