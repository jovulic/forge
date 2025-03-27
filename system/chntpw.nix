{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.chntpw;
in
with lib;
{
  options = {
    forge.system.chntpw = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable chntpw configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.chntpw
    ];
  };
}
