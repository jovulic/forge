{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.vnc;
in
with lib;
{
  options = {
    forge.system.vnc = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable vnc configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.tigervnc
    ];
  };
}
