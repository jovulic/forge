{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.baldursgate3;
in
with lib;
{
  options = {
    forge.system.baldursgate3 = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable baldursgate3 configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    networking = {
      firewall = {
        # lsof -i | grep bg3
        allowedUDPPorts = [
          23253
        ];
      };
    };
  };
}
