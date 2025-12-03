{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.displaymanager;
in
with lib;
{
  options = {
    forge.system.displaymanager = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable displaymanager configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    console = {
      font = null;
    };

    services.displayManager = {
      defaultSession = "sway";
      sddm = {
        enable = true;
        theme = "sddm-astronaut-theme";
        extraPackages = [
          pkgs.kdePackages.qtmultimedia
          pkgs.kdePackages.qt5compat
          pkgs.kdePackages.qtsvg
          pkgs.kdePackages.qtvirtualkeyboard
        ];
        wayland = {
          enable = true;
        };
      };
    };
    environment.systemPackages = [
      # sddm-greeter-qt6 --test-mode --theme /run/current-system/sw/share/sddm/themes/sddm-astronaut-theme
      pkgs.sddm-astronaut # displayManager.sddm.theme
    ];

    services.libinput = {
      enable = true;
    };

    services.xserver = {
      enable = true;
      videoDrivers = [
        "modesetting"
        "fbdev"
      ];
    };
    # services.desktopManager = {
    #   plasma6 = {
    #     enable = true;
    #   };
    # };
  };
}
