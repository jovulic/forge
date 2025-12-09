{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.user;
in
with lib;
{
  options = {
    forge.system.user = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable user configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    users.users.me = {
      isNormalUser = true;
      initialPassword = "password";
      extraGroups = [
        "dialout" # full access to serial ports
        "podman" # work with podman via docker socket
        "libvirtd" # work with vms
        "networkmanager" # work with network
        "video" # control backlight
        "wheel" # admin access
        "dialout" # full access to serial ports (for plover)
        "wireshark" # allow for packet capture in wireshark
        "openrazer" # allow access to openrazer without password
        "corectrl" # allow usage of corectrl without password
        "adbusers" # allow usage of adb (android debug bridge)
      ];
      shell = pkgs.fish;
    };
  };
}
