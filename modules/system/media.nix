{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.media;
in
with lib;
{
  options = {
    forge.system.media = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable media configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
    };

    environment.etc = {
      "wireplumber/bluetooth.lua.d/51-bluez-config.lua".text = ''
        bluez_monitor.properties = {
          ["bluez5.enable-sbc-xq"] = true,
          ["bluez5.enable-msbc"] = true,
          ["bluez5.enable-hw-volume"] = true,
          ["bluez5.headset-roles"] = "[ hsp_hs hsp_ag hfp_hf hfp_ag ]"
        }
      '';
    };
  };
}
