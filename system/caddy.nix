{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.caddy;
in
with lib;
{
  options = {
    forge.system.caddy = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable caddy configuration. The service is used to route traffic to locally running services. The other part to this derivation is netowrking configuration for each host.";
      };
    };
  };
  config = mkIf cfg.enable {
    # NB(jv): Remember to update core's networking.extraHosts if adding new
    # hosts.
    services.caddy = {
      enable = true;
      extraConfig = ''
        chat.localhost {
          reverse_proxy 127.0.0.1:8081
        }
      '';
    };
  };
}
