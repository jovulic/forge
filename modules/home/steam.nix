{
  config,
  lib,
  pkgs,
  chaotic ? null,
  ...
}:
let
  cfg = config.forge.home.steam;
in
with lib;
{
  options = {
    forge.home.steam = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable home-manager Steam and compatibility tools configuration.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Symlink Proton tools to compatibilitytools.d so Heroic Games Launcher and
    # other launchers can find them.
    home.file = {
      ".steam/root/compatibilitytools.d/proton-ge-bin" = {
        source = pkgs.proton-ge-bin.steamcompattool;
      };
    }
    // lib.optionalAttrs (chaotic != null && chaotic ? packages) {
      ".steam/root/compatibilitytools.d/proton-cachyos" = {
        source = chaotic.packages.${pkgs.system}.proton-cachyos;
      };
      ".steam/root/compatibilitytools.d/proton-cachyos_x86_64_v3" = {
        source = chaotic.packages.${pkgs.system}.proton-cachyos_x86_64_v3;
      };
    };
  };
}
