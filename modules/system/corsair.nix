{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.corsair;
in
with lib;
{
  options = {
    forge.system.corsair = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable corsair configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # Not working and the steps to use are unclear. Backburner for now.
    # environment.systemPackages = [
    #   pkgs.openlinkhub
    # ];

    # issue: https://github.com/nixos/nixpkgs/issues/444209
    hardware.ckb-next = {
      enable = true;
      package = pkgs.ckb-next.overrideAttrs (final: {
        cmakeFlags = (final.cmakeFlags or [ ]) ++ [ "-DUSE_DBUS_MENU=0" ];
      });
    };
  };
}
