{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.yazi;
  yazi-media-view = pkgs.writeShellApplication {
    name = "yazi-media-view";
    runtimeInputs = [
      pkgs.file
      pkgs.mpv
      pkgs.libnotify
      pkgs.coreutils
      pkgs.xdg-utils
    ];
    text = builtins.readFile ./yazi-media-view.sh;
  };
in
with lib;
{
  options = {
    forge.home.yazi = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable yazi modern terminal file manager.";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      shellWrapperName = "y";
      enableFishIntegration = true;
      enableBashIntegration = true;
      extraPackages = [
        yazi-media-view
      ];

      settings = {
        mgr = {
          # Give the preview pane a majority of the screen.
          # Ratio: Parent (1/8), Current (3/8), Preview (4/8 = 50%)
          ratio = [
            1
            3
            4
          ];
        };
        preview = {
          max_width = 1600;
          max_height = 1200;
        };
        plugin = {
          prepend_previewers = [
            # Route all video files to the video timeline plugin.
            {
              mime = "video/*";
              run = "video-timeline";
            }
          ];
        };
      };

      keymap = {
        mgr.prepend_keymap = [
          {
            on = [ "i" ];
            run = "shell --block --confirm -- yazi-media-view \"%h\"";
            desc = "Play or show media in full quality";
          }
        ];
      };

      plugins = {
        video-timeline = ./plugins/video-timeline.yazi;
      };
    };
  };
}
