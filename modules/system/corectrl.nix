{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.corectrl;
in
with lib;
{
  options = {
    forge.system.corectrl = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable corectrl configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.corectrl = {
      enable = true;
    };

    # Unlock advanced AMDGPU features like custom power states, voltages, and
    # fan curves in CoreCtrl.
    # Verify with cat /sys/module/amdgpu/parameters/ppfeaturemask
    boot.kernelParams = [ "amdgpu.ppfeaturemask=0xffffffff" ];
  };
}
