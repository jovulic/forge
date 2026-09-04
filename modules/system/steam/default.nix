{
  config,
  lib,
  pkgs,
  unstablepkgs,
  ...
}:
let
  cfg = config.forge.system.steam;
in
with lib;
{
  options = {
    forge.system.steam = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable stream configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # https://wiki.nixos.org/wiki/GameMode
    # steam > gamemoderun %command%
    #
    # Configure GameMode to renice game processes and set AMD performance
    # levels on start.
    # Verify with `gamemoded -s` and watch for desktop start/end notifications.
    programs.gamemode = {
      enable = true;
      enableRenice = true;
      settings = {
        general = {
          renice = 10;
        };
        gpu = mkIf (config.forge.system.gpu.vendor != "none") {
          apply_gpu_optimisations = "accept-responsibility";
          gpu_vendor = config.forge.system.gpu.vendor;
          amd_performance_level = mkIf (config.forge.system.gpu.vendor == "amd") "high";
        };
        custom = {
          start = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'GameMode started'";
          end = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'GameMode ended'";
        };
      };
    };

    programs.gamescope = {
      enable = true;
      capSysNice = false;
    };

    programs.steam = {
      enable = true;

      # https://wiki.nixos.org/wiki/Steam#gamescope
      gamescopeSession = {
        enable = true;
      };

      extraPackages = [
        pkgs.mangohud
        pkgs.xdg-utils
      ];

      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };

    environment.systemPackages = [
      pkgs.protontricks # a simple wrapper for running winetricks commands for proton-enabled games
      pkgs.protonup-qt # install and manage proton-ge for steam
    ];

    # NOTE: Command to iterate over all SteamVR shared object files printing out dependencies that do not exist.
    #
    # find ~/.local/share/Steam/steamapps/common/SteamVR/ -name "*.so*" | while read line ; do echo "Printing $line"; ldd $line | grep "not found" ; done
  };
}
