{ pkgs, ... }: {
  imports = [
    ../../modules/home
  ];

  # MacOS home settings.
  home.username = "josipvulic";
  home.stateVersion = "26.05";

  # Enable shared configurations that are platform-agnostic.
  forge.home = {
    core = {
      username = "josipvulic";
      homeDirectory = "/Users/josipvulic";
    };
    fish.enable = true;
    ghostty.enable = true;

    # Disable linux-specific hardware and desktop modules.
    sway.enable = false;
    waybar.enable = false;
    vr.enable = false;
    lllm.enable = false;
    plover.enable = false;
  };

  # Aerospace window management config.
  home.file.".config/aerospace/aerospace.toml".text = ''
    start-at-login = true

    enable-normalization-flatten-containers = true
    enable-normalization-opposite-orientation-for-nested-containers = true

    [gaps]
    inner.horizontal = 8
    inner.vertical = 8
    outer.horizontal = 8
    outer.vertical = 8

    [mode.main.binding]
    # Workspace Navigation (Alt/Option modifier)
    alt-1 = 'workspace 1'
    alt-2 = 'workspace 2'
    alt-3 = 'workspace 3'
    alt-4 = 'workspace 4'
    alt-5 = 'workspace 5'
    alt-6 = 'workspace 6'
    alt-7 = 'workspace 7'
    alt-8 = 'workspace 8'
    alt-9 = 'workspace 9'

    # Move windows across workspaces
    alt-shift-1 = 'move-node-to-workspace 1'
    alt-shift-2 = 'move-node-to-workspace 2'
    alt-shift-3 = 'move-node-to-workspace 3'
    alt-shift-4 = 'move-node-to-workspace 4'
    alt-shift-5 = 'move-node-to-workspace 5'
    alt-shift-6 = 'move-node-to-workspace 6'
    alt-shift-7 = 'move-node-to-workspace 7'
    alt-shift-8 = 'move-node-to-workspace 8'
    alt-shift-9 = 'move-node-to-workspace 9'

    # Vim-style focus controls (h j k l)
    alt-h = 'focus left'
    alt-j = 'focus down'
    alt-k = 'focus up'
    alt-l = 'focus right'

    # Vim-style move window controls (Shift + h j k l)
    alt-shift-h = 'move left'
    alt-shift-j = 'move down'
    alt-shift-k = 'move up'
    alt-shift-l = 'move right'

    # Window layouts
    alt-f = 'fullscreen'
    alt-shift-space = 'layout floating'

    # Quick Terminal Launch
    alt-enter = 'exec-and-forget open -a Ghostty'
  '';
}
