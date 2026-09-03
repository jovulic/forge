{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.lact;
in
with lib;
{
  options = {
    forge.system.lact = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable LACT configuration.";
      };
    };
  };

  config = mkIf cfg.enable {
    services.lact = {
      enable = true;
    };

    # LACT needs access to `sudo` to query/monitor GameMode status on behalf of
    # user sessions. On NixOS, `sudo` is a setuid wrapper located in
    # `/run/wrappers/bin`.
    systemd.services.lactd.path = [ "/run/wrappers" ];

    # Over overdrive is needed for overclocking/undervolting AMD GPUs.
    hardware.amdgpu.overdrive.enable = mkIf (config.forge.system.gpu.vendor == "amd") true;

    assertions = [
      {
        assertion = !config.forge.system.corectrl.enable;
        message = "LACT and CoreCtrl cannot be enabled at the same time. Please disable one of them.";
      }
    ];
  };
}
