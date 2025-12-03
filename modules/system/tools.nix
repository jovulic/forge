{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.forges;
in
with lib;
{
  options = {
    forge.system.forges = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable tools configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.bc # commandline arithmetic
      pkgs.dig # better dns tool than nslookup
      pkgs.mesa-demos # Collection of demos and test programs for OpenGL and Mesa (glxinfo)
      pkgs.gnumake # provides make
      pkgs.host.dnsutils # add dns tools like nslookup
      pkgs.htop # fancy process viewer
      pkgs.iw # advanced control over wireless devices
      pkgs.jq # commandline json processor
      pkgs.yq # commandline yaml processor
      pkgs.libinput # debug input devices and xorg compat with wayland
      pkgs.libnotify # provides notify-send
      pkgs.lshw # information around hardware
      pkgs.lsof # the lsof tool for easily finding services listening on ports
      pkgs.nmap # read and write data across networks
      pkgs.parted # mostly for partprobe
      pkgs.pciutils # pci utilities, namly lspci
      pkgs.pstree # print processes in a tree form
      pkgs.pv # pipeview a usful utility
      pkgs.ripgrep # better grep
      pkgs.sysstat # monitoring tools like mpstat and iostat
      pkgs.tcpdump # it dumps tcp
      pkgs.tree # print directires in a tree-like format
      pkgs.usbutils # usb utilities like lsusb
      pkgs.wavemon # wireless device monitor
      pkgs.wev # debug input events in wayland
      pkgs.xdg-utils # xdg related utilities
      pkgs.killall # the killall command
      pkgs.iftop # network bandwidth monitoring
      pkgs.nethogs # network bandwidth monitoring by process
      pkgs.jc # tool to convert system command output to json https://github.com/kellyjonbrazil/jc
      pkgs.traceroute # tool to debug routing
      pkgs.iperf # a network performance testing tool
      pkgs.zip # zip
      pkgs.unzip # and unzip
      pkgs.rar # rar
      pkgs.unrar # and unrar
      pkgs.gdu # disk usage analyzer with console interface
      pkgs.bottom # a cross-platform graphical process/system monitor with a customizable interface
      pkgs.hardinfo2 # display information about your hardware and operating system
      pkgs.ethtool # query or control network driver and hardware settings
      pkgs.xorg.xhost # used to add and delete hosts and users to the list allowed to make connections to the X server (eg. xhost si:localuser:root and xhost -si:localuser:root)
      pkgs.p7zip # extra 7z archives with 7za.
      pkgs.radeon-profile # application to read current clocks of ati radeon cards
      # error: configure: error: Couldn't figure out how to access libc
      # pkgs.trickle # lightweight userspace bandwidth shaper
      pkgs.patchelf # a small utility to modify the dynamic linker and RPATH of ELF executables
      pkgs.dive # a tool for exploring each layer of a docker image
      pkgs.ydotool # generic Linux command-line automation tool
      pkgs.nix-tree # interactively browse a Nix store paths dependencies
      pkgs.minicom # modem control and terminal emulation program
      pkgs.feh # lightweight image viewer
      pkgs.inotify-tools # notify tools such as "inotifywait -m" which can be used to watch a file for changes
      pkgs.audit # audit library giving the ability to audit this such as file for changes
      pkgs.nix-inspect # interactive tui for inspecting nix configs and other expressions
    ];

    # A network traffic and packet inspection tool.
    programs.wireshark = {
      enable = true;
    };

    # A continuous traceroute-like tool.
    programs.mtr = {
      enable = true;
    };
  };
}
