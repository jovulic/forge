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
    # We give steam a patched brwap that allows applications then to
    # access high priority contexts.
    # https://wiki.nixos.org/wiki/VR#SteamVR
    #
    # Additional, you may also need to replace Steam's own bwrap binary with a
    # symbolic link to this modified bwrap binary, found at
    # ~/.local/share/Steam/ubuntu12_32/steam-runtime/usr/libexec/steam-runtime-tools-0/srt-bwrap.
    # Steam will periodically replace this modification with its own binary
    # when steam-runtime updates, so you may need to re-apply this change if it
    # breaks.
    programs.steam =
      let
        patchedBwrap = pkgs.bubblewrap.overrideAttrs (o: {
          patches = (o.patches or [ ]) ++ [
            ../../../patches/bwrap.patch
          ];
        });
      in
      {
        enable = true;
        package = pkgs.steam.override {
          buildFHSEnv = (
            args:
            (
              (pkgs.buildFHSEnv.override {
                bubblewrap = patchedBwrap;
              })
              (
                args
                // {
                  extraBwrapArgs = (args.extraBwrapArgs or [ ]) ++ [ "--cap-add ALL" ];
                }
              )
            )
          );
        };
        # https://wiki.nixos.org/wiki/Steam#gamescope
        gamescopeSession = {
          enable = true;
        };
        extraCompatPackages = [
          pkgs.proton-ge-bin
        ];
      };

    # https://wiki.nixos.org/wiki/GameMode
    # steam > gamemoderun %command%
    programs.gamemode = {
      enable = true;
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
