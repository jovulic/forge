{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.golang;
in
with lib;
{
  options = {
    forge.system.golang = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable golang configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.go
    ];
  };
}
