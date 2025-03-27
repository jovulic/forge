{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.golang;
in
with lib;
{
  options = {
    forge.home.golang = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable golang configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.sessionVariables = {
      GOPRIVATE = "github.com/jovulic/";
    };
  };
}
