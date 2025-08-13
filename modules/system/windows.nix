{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.windows;
in
with lib;
{
  options = {
    forge.system.windows = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable windows configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.bottles.override { removeWarningPopup = true; })
    ];
  };
}
