{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.coolercontrol;
in
with lib;
{
  options = {
    forge.system.coolercontrol = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable coolercontrol configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.coolercontrol.coolercontrol-gui
    ];
    systemd = {
      packages = [
        pkgs.coolercontrol.coolercontrold
      ];

      # https://github.com/NixOS/nixpkgs/issues/81138
      services = {
        coolercontrold.wantedBy = [ "multi-user.target" ];
      };
    };
  };
}
