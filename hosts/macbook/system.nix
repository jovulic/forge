{
  nix-darwin,
  home-manager,
  system,
  pkgs,
  unstablepkgs,
  mypkgs,
  ...
}:
nix-darwin.lib.darwinSystem {
  inherit system;
  modules = [
    (
      { pkgs, ... }:
      {
        # Base packages.
        environment.systemPackages = [
          pkgs.vim
          pkgs.git
        ];

        users.users.josipvulic = {
          home = "/Users/josipvulic";
          shell = pkgs.fish;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGdXDo+F2+TVAwH3CLJnK2SUIJR/6HvBeHEcfQbYxjk cardno:37_277_509"
          ];
        };

        system.primaryUser = "josipvulic";

        # Enable openssh server.
        services.openssh.enable = true;

        # Shell configuration.
        programs.fish.enable = true;
        programs.zsh.enable = true; # default shell, required for bootstrapping

        # Keyboard configuration.
        system.keyboard = {
          enableKeyMapping = true;
          remapCapsLockToControl = true;
        };

        # MacOS system tuning.
        system.defaults = {
          dock = {
            autohide = true;
            show-recents = false;
            mru-spaces = false; # do not automatically rearrange spaces based on most recent use
          };
          finder = {
            AppleShowAllExtensions = true;
            FXPreferredViewStyle = "Nlsv"; # default list view
            _FXShowPosixPathInTitle = true; # show path in finder window title
          };
          NSGlobalDomain = {
            # Low-latency key repeat (units are in 15ms blocks).
            InitialKeyRepeat = 15; # 225ms delay
            KeyRepeat = 2; # 30ms repeat speed
          };
        };

        # Declarative homebrew management for graphical apps.
        homebrew = {
          enable = true;
          onActivation = {
            cleanup = "zap"; # prunes unlisted apps automatically
            autoUpdate = true;
            upgrade = true;
          };
          casks = [
            "ghostty" # modern gpu-accelerated terminal
            "aerospace" # sway-style tiling window manager
            "google-chrome" # primary browser
          ];
        };

        system.stateVersion = 6;
      }
    )
    home-manager.darwinModules.home-manager
    {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit unstablepkgs mypkgs;
          chaotic = null;
        };
        users.josipvulic = { pkgs, ... }: {
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
          };

          # Declarative git configuration with native ssh-based commit signing for macOS.
          programs.git = {
            enable = true;
            signing = {
              key = "~/.ssh/id_ed25519.pub";
              signByDefault = true;
            };
            settings = {
              user = {
                name = "Josip Vulic";
                email = "jovulic@gmail.com";
              };
              gpg = {
                format = "ssh";
                ssh.program = "/usr/bin/ssh-keygen";
              };
              init = {
                defaultBranch = "main";
              };
              pull = {
                rebase = true;
              };
              url = {
                "ssh://git@github.com/" = {
                  insteadOf = "https://github.com/";
                };
              };
            };
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
        };
      };
    }
  ];
}
