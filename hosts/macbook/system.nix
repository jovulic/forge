{ pkgs, ... }: {
  # Base packages.
  environment.systemPackages = [
    pkgs.vim
    pkgs.git
  ];

  users.users.josipvulic = {
    home = "/Users/josipvulic";
    shell = pkgs.fish;
  };

  system.primaryUser = "josipvulic";

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
