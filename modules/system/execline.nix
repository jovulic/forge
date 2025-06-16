{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.execline;
in
with lib;
{
  options = {
    forge.system.execline = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable execline configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ pkgs.execline ];
  };
}
