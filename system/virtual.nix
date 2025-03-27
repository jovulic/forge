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
    environment.systemPackages =  [
      pkgs.virt-manager
      pkgs.virtiofsd # used in host-guest directory sharing
    ];
    virtualisation = {
      docker = {
        enable = true;
        # daemon.settings = {
        #   insecure-registries = [ "optiplexm.lan:5000" ];
        # };
      };
      podman = {
        enable = true;

        # Create a `docker` alias for podman, to use it as a drop-in replacement
        # dockerCompat = true;
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
