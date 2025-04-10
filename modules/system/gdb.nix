{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.gdb;
in
with lib;
{
  options = {
    forge.system.gdb = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gdb configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.gdb
    ];
  };
}
