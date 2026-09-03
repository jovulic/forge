{ config
, lib
, ...
}:
let
  cfg = config.forge.home.terminal;
in
with lib;
{
  options = {
    forge.home.terminal = {
      name = mkOption {
        type = types.enum [ "ghostty" "foot" "alacritty" ];
        default = "ghostty";
        description = "The default terminal emulator for the user session.";
      };
    };
  };
}
