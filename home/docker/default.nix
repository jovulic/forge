{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.docker;
in
with lib;
{
  options = {
    forge.home.docker = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable docker configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      ".docker/config.json" = {
        source = ./config.json;
      };
    };
  };
}
