{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.vr;
in
with lib;
{
  options = {
    forge.system.vr = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable VR configuration.";
      };

      backend = mkOption {
        type = types.enum [
          "alvr"
          "wivrn"
        ];
        default = "wivrn";
        description = "Which VR backend to use.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.backend == "alvr") {
      programs.alvr = {
        enable = true;
        openFirewall = true;
      };

      environment.systemPackages = [
        pkgs.wayvr
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
        '')
      ];
    })

    (mkIf (cfg.backend == "wivrn") {
      environment.systemPackages = [
        pkgs.opencomposite
      ];

      services.wivrn = {
        enable = true;
        openFirewall = true;
        highPriority = true;
        steam.importOXRRuntimes = true;
        config = {
          enable = true;
          json = {
            application = [ pkgs.wayvr ];
          };
        };
      };
    })
  ]);
}
