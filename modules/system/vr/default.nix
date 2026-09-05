{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.vr;
  xrizer = pkgs.xrizer.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "0.5-2026-09-03";
      src = pkgs.fetchFromGitHub {
        owner = "Supreeeme";
        repo = "xrizer";
        rev = "0989a7fac2d1efb7ea82f5fe1a8ed30c3eeb9596";
        hash = "sha256-Rb1pssAq6Zx6VmQVQtGcThkA6zCwi5X7G7aHmdsDrJo=";
      };
      cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) src;
        hash = "sha256-JKQUrHGqnU5453iVKXnO51nX2NqcBYzsfvuu92WhLDE=";
      };
      postPatch = ''
        substituteInPlace src/graphics_backends/gl.rs \
          --replace-fail 'libGLX.so.0' '${lib.getLib pkgs.libGL}/lib/libGLX.so.0'
      '';
    }
  );
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
    {
      warnings =
        if (cfg.backend == "wivrn" && config.forge.system.gpu.vendor == "none") then
          [
            "WiVRn is enabled, but forge.system.gpu.vendor is 'none'. No hardware-accelerated encoder config will be generated for WiVRn, causing a fallback to slow CPU encoding."
          ]
        else
          [ ];

      environment.systemPackages = [
        (pkgs.writeShellApplication {
          name = "vr-diag";
          runtimeInputs = [
            pkgs.android-tools
            pkgs.iproute2
            pkgs.iputils
            pkgs.gnugrep
            pkgs.gawk
            pkgs.jq
            pkgs.bc
            pkgs.procps
            pkgs.coreutils
          ];
          text = builtins.readFile ./vr-diag.sh;
        })
      ];
    }

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
        pkgs.wayvr
        xrizer
      ];

      services.wivrn = {
        enable = true;
        openFirewall = true;
        highPriority = true;
        steam = {
          enable = true;
          importOXRRuntimes = true;
        };
        config = {
          enable = true;
          json = mkMerge [
            (mkIf (config.forge.system.gpu.vendor == "amd") {
              encoder = "vulkan";
              encoders = [
                {
                  codec = "h265";
                  encoder = "vulkan";
                  height = 1.0;
                  offset_x = 0.0;
                  offset_y = 0.0;
                  width = 1.0;
                }
              ];
            })
            (mkIf (config.forge.system.gpu.vendor == "intel") {
              encoder = "vaapi";
              encoders = [
                {
                  codec = "h265";
                  encoder = "vaapi";
                  height = 1.0;
                  offset_x = 0.0;
                  offset_y = 0.0;
                  width = 1.0;
                }
              ];
            })
            (mkIf (config.forge.system.gpu.vendor == "nvidia") {
              encoder = "nvenc";
              encoders = [
                {
                  codec = "h265";
                  encoder = "nvenc";
                  height = 1.0;
                  offset_x = 0.0;
                  offset_y = 0.0;
                  width = 1.0;
                }
              ];
            })
          ];
        };
      };
    })
  ]);
}
