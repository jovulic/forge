{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.pulseaudio;
in
with lib;
{
  options = {
    forge.system.pulseaudio = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable pulseaudio configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # We get pw-cli (pw-*) and wpctl from pipewire.
    environment.systemPackages =  [
      pkgs.pulseaudio # pactl
      pkgs.pavucontrol
    ];
  };
}
