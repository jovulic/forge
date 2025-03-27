{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.ranger;
in
with lib;
{
  options = {
    forge.home.ranger = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ranger configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # $ ranger --copy-config=all
    # https://github.com/ranger/ranger/wiki/Image-Previews#with-mpv
    home.file = {
      ".config/ranger/commands_full.py" = {
        source = ./commands_fully.py;
      };
      ".config/ranger/commands.py" = {
        source = ./commands.py;
      };
      ".config/ranger/rc.conf" = {
        source = ./rc.conf;
      };
      ".config/ranger/rifle.conf" = {
        source = ./rifle.conf;
      };
      ".config/ranger/scope.sh" = {
        source = ./scope.sh;
        executable = true;
      };
    };
  };
}
