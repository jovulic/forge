{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.dbeaver;
in
with lib;
{
  options = {
    forge.system.dbeaver = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable dbeaver configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.dbeaver-bin
    ];
  };
}
