{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.ananicy;
in
with lib;
{
  options = {
    forge.system.ananicy = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ananicy configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # Service that manages process priorities.
    services.ananicy = {
      enable = true;
      package = pkgs.ananicy-cpp;
      rulesProvider = pkgs.ananicy-cpp;
    };
  };
}
