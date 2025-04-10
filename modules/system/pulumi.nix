{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.pulumi;
in
with lib;
{
  options = {
    forge.system.pulumi = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable pulumi configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.pulumi-bin
    ];
  };
}
