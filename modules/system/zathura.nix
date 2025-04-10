{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.zathura;
in
with lib;
{
  options = {
    forge.system.zathura = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable zathura configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.zathura
    ];
  };
}
