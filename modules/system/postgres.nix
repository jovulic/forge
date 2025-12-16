{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.postgres;
in
with lib;
{
  options = {
    forge.system.postgres = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable postgres configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.postgresql
      pkgs.pgadmin4-desktopmode
    ];
  };
}
