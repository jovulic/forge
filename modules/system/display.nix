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
        theme = "chili";
        # wayland = {
        #   enable = true;
        # };
      };
    };
    environment.systemPackages = [
      # sddm-greeter --test-mode --theme /run/current-system/sw/share/sddm/themes/chili
      pkgs.sddm-chili-theme # displayManager.sddm.theme
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
