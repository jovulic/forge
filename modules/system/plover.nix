{
  config,
  lib,
  mypkgs,
  ...
}:
let
  cfg = config.forge.system.plover;
in
with lib;
{
  options = {
    forge.system.plover = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable plover configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [ mypkgs.plover ];
  };
}
