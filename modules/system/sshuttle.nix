{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.sshuttle;
in
with lib;
{
  options = {
    forge.system.sshuttle = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable sshuttle configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.sshuttle
    ];
  };
}
