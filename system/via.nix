{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.via;
in
with lib;
{
  options = {
    forge.system.via = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable via configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      # https://github.com/NixOS/nixpkgs/blob/nixos-22.05/pkgs/tools/misc/via/default.nix#L35
      # Examples on using appimage installs.
      pkgs.via
    ];
    services.udev = {
      packages = [
        (pkgs.writeTextFile {
          name = "viia";
          text = ''
            KERNEL=="hidraw*", SUBSYSTEM=="hidraw", MODE="0666", TAG+="uaccess", TAG+="udev-acl"
          '';
          destination = "/etc/udev/rules.d/92-viia.rules";
        })
      ];
    };
  };
}
