{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.sshfs;

  sshfs-mount = pkgs.writeShellApplication {
    name = "sshfs-mount";
    runtimeInputs = [
      pkgs.sshfs
      pkgs.coreutils
      pkgs.util-linux # for mountpoint
      pkgs.gum
    ];
    text = builtins.readFile ./sshfs-mount.sh;
  };

  sshfs-unmount = pkgs.writeShellApplication {
    name = "sshfs-unmount";
    runtimeInputs = [
      pkgs.sshfs
      pkgs.coreutils
      pkgs.util-linux # for mountpoint
      pkgs.gnugrep
      pkgs.gawk
      pkgs.gum
    ];
    text = builtins.readFile ./sshfs-unmount.sh;
  };
in
with lib;
{
  options = {
    forge.system.sshfs = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable sshfs configuration with custom mount/unmount wrappers.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.sshfs
      sshfs-mount
      sshfs-unmount
    ];
  };
}
