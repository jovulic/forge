{
  config,
  pkgs,
  mypkgs,
  lib,
  ...
}:
let
  cfg = config.forge.system.volt;
in
with lib;
{
  options = {
    forge.system.volt = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable volt-gui configuration and Vulkan layers.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      mypkgs.volt-gui
    ];

    # Add the layers to the graphics configuration so the Vulkan loader can
    # find them natively.
    hardware.graphics = {
      extraPackages = [ mypkgs.volt-gui ];
      extraPackages32 = [ mypkgs.volt-gui.layer32 ];
    };
  };
}
