{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.alvr;
in
with lib;
{
  options = {
    forge.system.alvr = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable alvr configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.alvr = {
      enable = true;
      openFirewall = true;
    };
  };
}
