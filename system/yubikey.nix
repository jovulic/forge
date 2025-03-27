{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.yubikey;
in
with lib;
{
  options = {
    forge.system.yubikey = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable yubikey configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.fido2luks
      pkgs.yubikey-manager
    ];
  };
}
