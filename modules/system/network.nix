{
  config,
  options,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.network;
in
with lib;
{
  options = {
    forge.system.network = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable network configuration.";
      };
      hostName = mkOption {
        type = types.str;
        example = "optiplexm";
        description = options.networking.hostName.description;
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.iptables
      pkgs.nftables
      pkgs.iwgtk
    ];

    networking = {
      useNetworkd = true;

      hostName = cfg.hostName;

      wireless = {
        iwd = {
          enable = true;
        };
      };

      firewall = {
        enable = true;
      };

      extraHosts = ''
        127.0.0.1 chat.localhost
      '';
    };

    # We want to disable this wait as it can cause builds to fail if the
    # network does not get configured.
    systemd.network.wait-online.enable = false;

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
