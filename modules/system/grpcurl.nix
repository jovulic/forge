{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.grpcurl;
in
with lib;
{
  options = {
    forge.system.grpcurl = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable grpcurl configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.grpcurl
    ];
  };
}
