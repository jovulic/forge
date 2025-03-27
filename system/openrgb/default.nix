{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.openrgb;
in
with lib;
{
  options = {
    forge.system.openrgb = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable openrgb configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.openrgb
      pkgs.i2c-tools
    ];

    boot.kernelModules = [
      "i2c-dev"
      "i2c-pixx4"
    ];

    services.udev = {
      packages = [
        (pkgs.writeTextFile {
          name = "openrgb";
          text = builtins.readFile ./60-openrgb.rules;
          destination = "/etc/udev/rules.d/60-openrgb.rules";
        })
      ];
    };
  };
}
