{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.amd;
in
with lib;
{
  options = {
    forge.system.amd = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable amd configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.amdgpu_top
    ];

    programs.ryzen-monitor-ng = {
      enable = true;
    };
  };
}
