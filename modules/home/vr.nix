{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.vr;
  cfgGpu = config.forge.home.gpu;
in
with lib;
{
  options = {
    forge.home.vr = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable home-manager VR configuration.";
      };

      backend = mkOption {
        type = types.enum [
          "alvr"
          "wivrn"
        ];
        default = "wivrn";
        description = "Which VR backend to configure.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.backend == "wivrn") {
      home.file.".local/share/openvr/openvrpaths.vrpath" = {
        text = builtins.toJSON {
          config = [
            "${config.home.homeDirectory}/.local/share/Steam/config"
          ];
          external_drivers = null;
          log = [
            "${config.home.homeDirectory}/.local/share/Steam/logs"
          ];
          runtime = [
            "/run/current-system/sw/lib/xrizer"
          ];
        };
      };

      home.activation.checkWivrnSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        SETTINGS_FILE="$HOME/.config/wivrn/config.json"

        if [ -f "$SETTINGS_FILE" ]; then
          CURRENT_ENCODER=$(${pkgs.jq}/bin/jq -r '.encoder // "none"' "$SETTINGS_FILE" 2>/dev/null)
          CURRENT_CODEC=$(${pkgs.jq}/bin/jq -r '.encoders[0].codec // "none"' "$SETTINGS_FILE" 2>/dev/null)
          GPU_VENDOR="${cfgGpu.vendor}"

          if [ "$GPU_VENDOR" = "amd" ] || [ "$GPU_VENDOR" = "intel" ]; then
            if [ "$CURRENT_ENCODER" != "vaapi" ] && [ "$CURRENT_ENCODER" != "vulkan" ]; then
              echo "WARNING: WiVRn is not using a hardware-accelerated encoder (vaapi/vulkan) on your GPU!"
              echo "  Current encoder: $CURRENT_ENCODER. We recommend using vaapi."
            fi
            if [ "$CURRENT_CODEC" != "h265" ] && [ "$CURRENT_CODEC" != "hevc" ]; then
              echo "WARNING: WiVRn is not using H.265 (HEVC) on your GPU! H.264 might cause heavy streaming stutters."
              echo "  Current codec: $CURRENT_CODEC."
            fi
          elif [ "$GPU_VENDOR" = "nvidia" ]; then
            if [ "$CURRENT_ENCODER" != "nvenc" ]; then
              echo "WARNING: WiVRn is not using NVIDIA NVENC hardware acceleration!"
              echo "  Current encoder: $CURRENT_ENCODER."
            fi
            if [ "$CURRENT_CODEC" != "h265" ] && [ "$CURRENT_CODEC" != "hevc" ]; then
              echo "WARNING: WiVRn is not using H.265 (HEVC) with NVENC!"
              echo "  Current codec: $CURRENT_CODEC."
            fi
          fi
        else
          echo "NOTE: WiVRn config.json not found at $SETTINGS_FILE. Will fallback to system defaults."
        fi
      '';

      # Test via USB.
      # Run WiVRn on the host, then run the following commands.
      #
      # $ adb reverse tcp:9757 tcp:9757
      # $ adb shell am start -a android.intent.action.VIEW -d "wivrn+tcp://localhost" org.meumeu.wivrn
      #
      # It should then start up wivrn over USB via adb reverse port forward (WiVRn runs on port 9757).
      #
      # Ensure the headset is not connected to wireless to ensure it communicates only via USB.
    })
    {
      # dex ~/.nix-profile/share/applications/skyrimvr-fus.desktop
      xdg.desktopEntries."skyrimvr-fus" = {
        name = "SkyrimVR FUS";
        comment = "Launch SkyrimVR with FUS Modlist for WayVR";
        exec = "env STEAM_COMPAT_MOUNTS=\"/home/me/games/Modlist_Downloads\" PRESSURE_VESSEL_IMPORT_OPENXR_1_RUNTIMES=1 DXVK_FRAME_RATE=90 gamemoderun steam steam://rungameid/17981990352747233280";
        icon = "steam";
        terminal = false;
        type = "Application";
        categories = [
          "Game"
          "X-VR"
        ];
        settings = {
          X-WiVRn-VR = "true";
        };
      };
    }
  ]);
}
