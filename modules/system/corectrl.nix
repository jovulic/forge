{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.corectrl;
in
with lib;
{
  options = {
    forge.system.corectrl = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable corectrl configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.corectrl = {
      enable = true;
    };
  };
}
