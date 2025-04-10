{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.time;
in
with lib;
{
  options = {
    forge.system.time = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable time configuration.";
      };
      timezone = mkOption {
        type = types.str;
        example = "America/Toronto";
        description = "The name of name of the timezone. Select from this list https://en.wikipedia.org/wiki/List_of_tz_database_time_zones.";
        default = "America/Toronto";
      };
    };
  };
  config = mkIf cfg.enable {
    time.timeZone = cfg.timezone;
  };
}
