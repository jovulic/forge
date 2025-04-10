{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.forge.system.vulkan;
in
with lib;
{
  options = {
    forge.system.vulkan = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable vulkan configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.vulkan-tools # vulkaninfo
    ];
  };
}
