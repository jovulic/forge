{
  config,
  lib,
  mypkgs,
  ...
}:
let
  cfg = config.forge.system.helldivers2;
in
with lib;
{
  options = {
    forge.system.helldivers2 = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable Helldivers 2 configuration.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      mypkgs.hd2arsenal
    ];
  };
}
