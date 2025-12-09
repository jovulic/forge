{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.virtual;
in
with lib;
{
  options = {
    forge.system.virtual = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable virtual configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.virt-manager
      pkgs.virtiofsd # used in host-guest directory sharing
    ];
    virtualisation = {
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in
        # replacement
        dockerCompat = true;

        # Make the Podman socket available in place of the Docker socket, so
        # Docker tools can find the Podman socket.
        #
        # Users must be in the `podman` group in order to connect.
        dockerSocket.enable = true;
      };
      containers = {
        enable = true;
        # registries.insecure = [
        #   "optiplexm.lan:5000"
        # ];
      };
      libvirtd = {
        enable = true;
      };
    };
  };
}
