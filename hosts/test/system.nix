# The following creates a system using the nix overlay.
{
  nixpkgs,
  system,
  mypkgs,
  ...
}:
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit mypkgs;
  };
  modules = [
    (
      { mypkgs, ... }:
      {
        nixpkgs.overlays = [
          (import ../../overlays/nix { nix-shell-builtin = mypkgs.nix-shell-builtin; })
        ];
        environment.systemPackages = [ nixpkgs.nix ];
        system.stateVersion = "25.11";
      }
    )
  ];
}
