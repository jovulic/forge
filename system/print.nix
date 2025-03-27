{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.print;
in
with lib;
{
  options = {
    forge.system.print = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable print configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    services.printing = {
      enable = true;
      drivers = [ pkgs.hplip ];
    };

    services.avahi = {
      enable = true;
      nssmdns4 = true;
      openFirewall = true;
    };
  };
}
