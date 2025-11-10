{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.alacritty;
  tomlFormat = pkgs.formats.toml { };
in
with lib;
{
  options = {
    forge.home.alacritty = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable alacritty configuration.";
      };
      theme = mkOption {
        type = with lib.types; nullOr str;
        default = null;
        example = "solarized_dark";
        description = ''
          A theme from the
          [alacritty-theme](https://github.com/alacritty/alacritty-theme)
          repository to import in the configuration.
          See <https://github.com/alacritty/alacritty-theme/tree/master/themes>
          for a list of available themes.
          If you would like to import your own theme, use
          {option}`programs.alacritty.settings.general.import` or
          {option}`programs.alacritty.settings.colors` directly.
        '';
      };
      settings = lib.mkOption {
        type = tomlFormat.type;
        default = { };
        example = lib.literalExpression ''
          {
            window.dimensions = {
              lines = 3;
              columns = 200;
            };
            keyboard.bindings = [
              {
                key = "K";
                mods = "Control";
                chars = "\\u000c";
              }
            ];
          }
        '';
        description = ''
          Configuration written to
          {file}`$XDG_CONFIG_HOME/alacritty/alacritty.yml` or
          {file}`$XDG_CONFIG_HOME/alacritty/alacritty.toml`
          (the latter being used for alacritty 0.13 and later).
          See <https://github.com/alacritty/alacritty/tree/master#configuration>
          for more info.
        '';
      };
    };
  };
  config = mkIf cfg.enable {
    programs.alacritty = cfg // {
    };
  };
}
