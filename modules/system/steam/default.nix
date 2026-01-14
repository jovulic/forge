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
    programs.gamemode = {
      enable = true;
    };

    programs.gamescope = {
      enable = true;
      capSysNice = true;
    };

    programs.steam = {
      enable = true;

      # https://wiki.nixos.org/wiki/Steam#gamescope
      gamescopeSession = {
        enable = true;
      };

      extraCompatPackages = [
        pkgs.proton-ge-bin
      ];
    };

    environment.systemPackages = [
      pkgs.protontricks # a simple wrapper for running winetricks commands for proton-enabled games
      pkgs.protonup-qt # install and manage proton-ge for steam
      unstablepkgs.wlx-overlay-s # Wayland/X11 desktop overlay for SteamVR and OpenXR, Vulkan edition
      (pkgs.writeShellScriptBin "steamvr-patch" ''
        # Iterate over all shared object files under steamvr and run patch
        # referencing the steam FHS for libraries.
        STOREPATH=$(nix-store -qR `which steam` | grep steam-fhs)/lib64
        find ~/.local/share/Steam/steamapps/common/SteamVR/ -name "*.so*" | while read line ; do echo "Patching $line"; patchelf --add-rpath $STOREPATH $line ; done
        find /home/me/.local/share/Steam/steamapps/common/SteamVR/tools/steamvr_environments/game/steamtours/bin/linuxsteamrt64 -name "*.so*" | while read line ; do echo "Patching $line"; patchelf --add-rpath /home/me/.local/share/Steam/steamapps/common/SteamVR/tools/steamvr_environments/game/bin/linuxsteamrt64/ $line ; done
        find /home/me/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/ -name "*.so*" | while read line ; do echo "Patching $line"; patchelf --add-rpath $(dirname $line) $line ; done
        find /home/me/.local/share/Steam/steamapps/common/SteamVR/bin/linux64/ -name "*.so*" | while read line ; do echo "Patching $line"; patchelf --add-rpath /home/me/.local/share/Steam/steamapps/common/SteamVR/tools/steamvr_environments/game/bin/linuxsteamrt64/ $line ; done

        # Also, update the wlx-overlay-s manifest store path. It can become
        # an issue if the one currently referenced in garbage collected.
        echo "Update wlx-overlay-s manifest"
        wlx-overlay-s --replace
      '') # script that patches a variety of files related to SteamVR.
    ];

    # NOTE: Command to iterate over all SteamVR shared object files printing out dependencies that do not exist.
    #
    # find ~/.local/share/Steam/steamapps/common/SteamVR/ -name "*.so*" | while read line ; do echo "Printing $line"; ldd $line | grep "not found" ; done
  };
}
