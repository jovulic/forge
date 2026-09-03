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
        custom =
          let
            lactTrigger = pkgs.writeShellScript "lact-trigger" "sleep infinity";
          in
          {
            start = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'GameMode started' && ${lactTrigger} & echo $! > /tmp/lact-trigger.pid";
            end = "${pkgs.libnotify}/bin/notify-send 'GameMode' 'GameMode ended' && kill -9 $(cat /tmp/lact-trigger.pid) || true";
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
      ];

      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };

    environment.systemPackages = [
      pkgs.protontricks # a simple wrapper for running winetricks commands for proton-enabled games
      pkgs.protonup-qt # install and manage proton-ge for steam
      unstablepkgs.wayvr # Your way to enjoy VR on Linux! Access your Wayland/X11 desktop from SteamVR/Monado (OpenVR+OpenXR support)
      (pkgs.writeShellScriptBin "steamvr-patch" ''
        # Iterate over all shared object files under steamvr and run patch
        # referencing the steam FHS for libraries.
        STOREPATH=$(nix-store -qR `which steam` | grep steam-fhs)/lib64
        find ~/.local/share/Steam/steamapps/common/SteamVR/ -name "*.so*" | while read line ; do echo "Patching $line"; patchelf --add-rpath $STOREPATH $line ; done
        find /home/me/.local/share/Steam/steamapps/common/SteamVR/tools/steamvr_environments/game/steamtours/bin/linuxsteamrt64 -name "*.so*" | while read line ; do echo "Patching $line"; patchelf --add-rpath /home/me/.local/share/Steam/steamapps/common/SteamVR/tools/steamvr_environments/game/bin/linuxsteamrt64/ $line ; done
        find /home/me/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/ -name "*.so*" | while read line ; do echo "Patching $line"; patchelf --add-rpath $(dirname $line) $line ; done
        find /home/me/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/ -name "*.so*" | while read line ; do echo "Patching $line"; patchelf --add-rpath /home/me/.local/share/Steam/steamapps/common/SteamVR/tools/steamvr_environments/game/bin/linuxsteamrt64/ $line ; done

        # Also, update the wayvr manifest store path. It can become an issue if
        # the one currently referenced in garbage collected.
        echo "Update wayvr manifest"
        wayvr --replace
      '') # script that patches a variety of files related to SteamVR.
    ];

    # NOTE: Command to iterate over all SteamVR shared object files printing out dependencies that do not exist.
    #
    # find ~/.local/share/Steam/steamapps/common/SteamVR/ -name "*.so*" | while read line ; do echo "Printing $line"; ldd $line | grep "not found" ; done
  };
}
