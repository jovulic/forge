{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.bashly;
in
with lib;
{
  options = {
    forge.system.bashly = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable bashly configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.bashly
    ];
  };
}
