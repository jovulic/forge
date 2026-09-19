{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.sshfs;
in
with lib;
{
  options = {
    forge.system.sshfs = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable sshfs configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.sshfs
    ];
  };
}
