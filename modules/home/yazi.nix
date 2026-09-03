{ config
, lib
, ...
}:
let
  cfg = config.forge.home.yazi;
in
with lib;
{
  options = {
    forge.home.yazi = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable yazi modern terminal file manager.";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableFishIntegration = true;
      enableBashIntegration = true;
    };
  };
}
