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
        # https://larian.com/support/faqs/multiplayer-issues_84
        # lsof -i | grep bg3
        allowedUDPPortRanges = [
          {
            from = 23253;
            to = 23262;
          }
          {
            from = 23243;
            to = 23252;
          }
        ];
      };
    };
  };
}
