{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.openssl;
in
with lib;
{
  options = {
    forge.system.openssl = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable openssl configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.openssl
    ];
  };
}
