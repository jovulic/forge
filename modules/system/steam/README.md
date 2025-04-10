# steam

# Variants

## Installed via flatpak

Configuring steam via flatpak involves executing the following commands.

```
$ flatpak remote-add --if-not-exists flathub https://dl.flathub.org/repo/flathub.flatpakrepo
$ flatpak install flathub com.valvesoftware.Steam
$ flatpak install flathub org.freedesktop.Platform.VulkanLayer.gamescope
# setcap 'CAP_SYS_NICE=eip' <gamescope-binary>
$ flatpak install flathub org.freedesktop.Platform.VulkanLayer.MangoHud
$ flatpak install flathub org.freedesktop.Platform.VulkanLayer.vkBasalt
$ flatpak install flathub com.github.Matoking.protontricks
$ flatpak install flathub com.valvesoftware.Steam.CompatibilityTool.Proton
$ flatpak install flathub com.valvesoftware.Steam.CompatibilityTool.Proton-GE
$ flatpak install flathub com.github.tchx84.Flatseal
```

## With gamemode, gamescope, and mangohud

The following is the nix steam configuration that included support for `gamemode`, `gamescope`, and `mangohud`.

However, it is more here for posterity, as in the future it should be introduced again in steps (and likely using more of the built-in options off the steam config).

```
nixpkgs.config.packageOverrides = pkgs: {
  steam = pkgs.steam.override {
    extraPkgs = pkgs: with pkgs; [
      # Fixes undefined symbols in X11 session.
      # source: https://github.com/NixOS/nixpkgs/issues/162562#issuecomment-1229444338
      xorg.libXcursor
      xorg.libXi
      xorg.libXinerama
      xorg.libXScrnSaver
      libpng
      libpulseaudio
      libvorbis
      stdenv.cc.cc.lib
      libkrb5
      keyutils

      # Not sure, but I think this makes mangohud, gamemoderun, and gamescope available within steam?
      mangohud
      gamemode
      gamescope
    ];
  };
};

programs.steam = {
  enable = true;
};

environment.systemPackages = with pkgs; [
  mangohud # a Vulkan and OpenGL overlay for monitoring FPS, temperatures, CPU/GPU load and more
  protontricks # a wrapper script to operate on proton games (https://github.com/Matoking/protontricks)
];

# a microcompositor from Valve to provide an isolated compositor that is tailored towards gaming
programs.gamescope = {
  enable = true;
  # capSysNice = true; # running into "bwrap: Unexpected capabilities but not setuid, old file caps config?" error.
};

# # a daemon/lib combo for Linux that allows games to request a set of optimisations be temporarily applied to the host OS and/or a game process
programs.gamemode = {
  enable = true;
};
```

# Notes

## Run games with gamescope, mangohud, and gamemode

Add the following launch options for the game.

```
gamescope -W 2560 -H 1440 -r 60 -f -e -- mangohud gamemoderun %command%
```

## Run games manually

The following is an example command that will startup Starship Troopers Extermination and Baulder's Gate 3.

```
# STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam" \
# STEAM_COMPAT_DATA_PATH="/home/me/.steam/steam/steamapps/compatdata/1268750" \
# gamescope -W 2560 -H 1440 -r 60 -f -- steam-run "/home/me/.steam/root/steamapps/common/Proton - Experimental/proton" run "/home/me/.steam/steam/steamapps/common/StarshipTroopersExtermination/Yakisoba.exe"

# STEAM_COMPAT_CLIENT_INSTALL_PATH="$HOME/.steam/steam" \
# STEAM_COMPAT_DATA_PATH="/home/me/.steam/steam/steamapps/compatdata/1086940" \
# gamescope -W 2560 -H 1440 -r 60 -f -- steam-run "/home/me/.steam/root/steamapps/common/Proton - Experimental/proton" run "/home/me/.steam/steam/steamapps/common/Baldurs Gate 3/Launcher/LariLauncher.exe" --skip-launcher
```
