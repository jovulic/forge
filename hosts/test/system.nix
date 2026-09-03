# The following creates a system using the nix overlay.
{
  nixpkgs,
  system,
  mypkgs,
  unstablepkgs,
  ...
}:
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit mypkgs unstablepkgs;
  };
  modules = [
    ../../modules/system
    (
      { pkgs, mypkgs, ... }:
      {
        nixpkgs.overlays = [
          (import ../../overlays/nix { nix-shell-builtin = mypkgs.nix-shell-builtin; })
        ];
        environment.systemPackages = [ pkgs.nix ];
        system.stateVersion = "25.11";

        # Disable core boot and storage configuration for testing, and provide
        # a clean in-memory tmpfs root stub instead.
        forge.system.boot.enable = false;

        fileSystems."/" = {
          device = "none";
          fsType = "tmpfs";
        };
        boot.loader.grub.enable = false;

        # Set network hostname to satisfy networking module requirements
        forge.system.network.hostName = "test";
      }
    )
  ];
}
