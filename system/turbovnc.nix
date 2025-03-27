{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.turbovnc;
in
with lib;
{
  options = {
    forge.system.turbovnc = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable turbovnc configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.turbovnc
    ];
  };
}
