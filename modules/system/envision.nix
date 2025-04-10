{
  config,
  lib,
  unstablepkgs,
  ...
}:
let
  cfg = config.forge.system.envision;
in
with lib;
{
  options = {
    forge.system.envision = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable envision configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # https://github.com/NixOS/nixpkgs/blob/71e91c409d1e654808b2621f28a327acfdad8dc2/nixos/modules/programs/envision.nix
    services.avahi = {
      enable = true;
      publish = {
        enable = true;
        userServices = true;
      };
    };

    services.udev = {
      enable = true;
      packages = with unstablepkgs; [
        android-udev-rules
        xr-hardware
      ];
    };

    environment.systemPackages = [ unstablepkgs.envision ];

    networking.firewall = {
      allowedTCPPorts = [ 9757 ];
      allowedUDPPorts = [ 9757 ];
    };
  };
}
