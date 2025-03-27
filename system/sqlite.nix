{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.sqlite;
in
with lib;
{
  options = {
    forge.system.sqlite = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable sqlite configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.sqlite
    ];
  };
}
