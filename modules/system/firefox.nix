{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.firefox;
in
with lib;
{
  options = {
    forge.system.firefox = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable firefox configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # Verify hardware acceleration, native Wayland, and active driver paths in
    # about:support.
    programs.firefox = {
      enable = true;
      policies = {
        ImportEnterpriseRoots = true;

        # Force hardware video decoding and bypass driver-safety blocklists.
        Preferences = {
          "media.ffmpeg.vaapi.enabled" = true;
          "media.rdd-process.enabled" = true;
          "gfx.webrender.all" = true;
        };
      };
    };

    environment.sessionVariables = {
      # Forces Firefox to run natively under Wayland (avoiding XWayland scaling
      # or tearing).
      MOZ_ENABLE_WAYLAND = "1";

      # Instructs the VA-API video decoding API to use AMD's Mesa driver
      # (radeonsi).
      LIBVA_DRIVER_NAME = "radeonsi";

      # Instructs the older VDPAU API to use AMD's Mesa driver (radeonsi) as a
      # fallback.
      VDPAU_DRIVER = "radeonsi";
    };
  };
}
