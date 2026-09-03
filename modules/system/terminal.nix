{ config
, lib
, ...
}:
let
  cfg = config.forge.system.terminal;
in
with lib;
{
  options = {
    forge.system.terminal = {
      name = mkOption {
        type = types.enum [ "ghostty" "foot" "alacritty" ];
        default = "ghostty";
        description = "The default terminal emulator for the system configuration.";
      };
    };
  };
}
