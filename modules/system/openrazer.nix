{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.openrazer;
in
with lib;
{
  options = {
    forge.system.openrazer = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable openrazer configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    hardware.openrazer = {
      enable = true;
      users = [ "me" ];
    };

    environment.systemPackages = [
      pkgs.polychromatic # graphical front-end and tray applet for configuring razer peripherals on gnu/linux
    ];
  };
}
