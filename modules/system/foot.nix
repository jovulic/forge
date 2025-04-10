{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.foot;
in
with lib;
{
  options = {
    forge.system.foot = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable foot configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.foot
    ];
  };
}
