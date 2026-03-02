{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.firefox;
in
with lib;
{
  options = {
    forge.system.firefox = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable firefox configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      policies = {
        ImportEnterpriseRoots = true;
      };
    };
  };
}
