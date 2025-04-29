{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.java;
in
with lib;
{
  options = {
    forge.home.java = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable java configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.sessionVariables = {
      # Certain Java apps can have issues running in a filed environment (like
      # sway) and this works around those sorts of issues.
      _JAVA_AWT_WM_NONREPARENTING = "1";
    };
  };
}
