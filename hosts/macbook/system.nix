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

          # fzf.fish dependencies
          pkgs.fzf
          pkgs.fd
          pkgs.bat

          # yazi preview dependencies
          pkgs.file
          pkgs.ffmpegthumbnailer
          pkgs.unar
          pkgs.jq
          pkgs.poppler-utils
          pkgs.ripgrep
          pkgs.zoxide
        ];

        users.users.jvulic = {
          home = "/Users/jvulic";
          shell = pkgs.fish;
          openssh.authorizedKeys.keys = [
            "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDGdXDo+F2+TVAwH3CLJnK2SUIJR/6HvBeHEcfQbYxjk cardno:37_277_509"
          ];
        };

        system.primaryUser = "jvulic";

        # Enable openssh server.
        services.openssh.enable = true;

        # Disable nix-darwin's management of the nix daemon to prevent
        # conflicts with determinate nix.
        nix.enable = false;

        # Shell configuration.
        programs.fish.enable = true;
        programs.zsh.enable = true; # default shell, required for bootstrapping
        environment.shells = [ pkgs.fish ];

        # Networking configuration.
        networking = {
          hostName = "macbook";
          computerName = "macbook";
          localHostName = "macbook";
        };

        # Keyboard configuration.
        system.keyboard = {
          enableKeyMapping = true;
          remapCapsLockToControl = true;
        };

        # Enable biometric sudo authentication using touch id.
        security.pam.services.sudo_local = {
          touchIdAuth = true; # fingerprint sudo
          reattach = true; # make touch id work inside multiplexers / terminal sessions
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
            "com.apple.swipescrolldirection" = false; # traditional mouse scroll direction
          };
        };

        # Declarative homebrew management for graphical apps.
        homebrew = {
          enable = true;
          onActivation = {
            autoUpdate = true;
            upgrade = true;
          };
          taps = [
            "nikitabobko/tap"
          ];
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
        users.jvulic = { pkgs, lib, ... }: {
          # MacOS home settings.
          home.username = "jvulic";
          home.homeDirectory = "/Users/jvulic";
          home.stateVersion = "26.05";
          home.enableNixpkgsReleaseCheck = true;

          # Let Home Manager install and manage itself.
          programs.home-manager.enable = true;

          # Suppress warning: programs.man.generateCaches has no effect when
          # programs.man.package is null
          programs.man.generateCaches = false;

          # Session variables.
          home.sessionVariables = {
            EDITOR = "nvim";
            GOOGLE_APPLICATION_CREDENTIALS = "$HOME/.config/gcloud/application_default_credentials.json";
          };

          # Fish configuration.
          programs.fish = {
            enable = true;
            interactiveShellInit = ''
              set fish_greeting
            '';
            plugins = [
              {
                name = "tide";
                src = pkgs.fetchFromGitHub {
                  owner = "IlanCosman";
                  repo = "tide";
                  rev = "v6.2.0";
                  sha256 = "sha256-1ApDjBUZ1o5UyfQijv9a3uQJ/ZuQFfpNmHiDWzoHyuw=";
                };
              }
              {
                name = "fzf";
                src = pkgs.fetchFromGitHub {
                  owner = "PatrickF1";
                  repo = "fzf.fish";
                  rev = "v11.0";
                  sha256 = "sha256-H7HgYT+okuVXo2SinrSs+hxAKCn4Q4su7oMbebKd/7s=";
                };
              }
              {
                name = "done";
                src = pkgs.fetchFromGitHub {
                  owner = "franciscolourenco";
                  repo = "done";
                  rev = "1.21.1";
                  sha256 = "sha256-GZ1ZpcaEfbcex6XvxOFJDJqoD9C5out0W4bkkn768r0=";
                };
              }
              {
                name = "forgit";
                src = pkgs.fetchFromGitHub {
                  owner = "wfxr";
                  repo = "forgit";
                  rev = "26.09.1";
                  sha256 = "sha256-02w+BGrRDEFWLtH6tniiTgs+FHmghiHn9FMxO+U4wrI=";
                };
              }
            ];
          };

          # Dircolors.
          programs.dircolors = {
            enable = true;
            enableFishIntegration = true;
            settings = {
              OTHER_WRITABLE = "01;36";
              STICKY_OTHER_WRITABLE = "01;34";
            };
          };

          # Yazi terminal file manager.
          programs.yazi = {
            enable = true;
            shellWrapperName = "y";
            enableFishIntegration = true;
            enableBashIntegration = true;
          };

          # Neovim text editor.
          programs.neovim = {
            enable = true;
            defaultEditor = true;
            viAlias = true;
            vimAlias = true;
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
                email = "jvulic@kevel.com";
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

          home.file.".config/fish/functions/_abbr_kube.fish".source = ./config/fish/_abbr_kube.fish;
          home.file.".config/fish/functions/_abbr_mount.fish".source = ./config/fish/_abbr_mount.fish;
          home.file.".config/fish/functions/_abbr_vim.fish".source = ./config/fish/_abbr_vim.fish;
          home.file.".config/fish/functions/fish_user_key_bindings.fish".source =
            ./config/fish/fish_user_key_bindings.fish;
          home.file.".docker/config.json".source = ./config/docker.json;
          home.file.".config/ghostty/config".source = ./config/ghostty;
          home.file.".config/aerospace/aerospace.toml".source = ./config/aerospace.toml;
        };
      };
    }
  ];
}
