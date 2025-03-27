{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.flashfocus;
in
with lib;
{
  options = {
    forge.system.flashfocus = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable flashfocus configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.flashfocus
    ];
  };
}
