{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.gephi;
in
with lib;
{
  options = {
    forge.system.gephi = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gephi configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.gephi
    ];
  };
}
