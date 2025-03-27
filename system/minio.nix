{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.minio;
in
with lib;
{
  options = {
    forge.system.minio = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable minio configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.minio-client
    ];
  };
}
