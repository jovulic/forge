{
  description = "Where I go to shape my machines.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
      unstablepkgs = import inputs.nixpkgs-unstable {
        inherit system;
      };
      mypkgs = pkgs.callPackage ./pkgs { };
      callPackage = pkgs.lib.callPackageWith {
        inherit pkgs;
        inherit unstablepkgs;
        inherit mypkgs;
      };
    in
    {
      devShells.${system}.default =
        let
          ctl = pkgs.writeShellApplication {
            name = "ctl";
            runtimeInputs = [
              pkgs.figlet
            ];
            text = builtins.readFile ./ctl/ctl;
            bashOptions = [
              "errexit"
              "pipefail"
            ];
          };
        in
        pkgs.mkShell {
          packages = [
            pkgs.bashly
            pkgs.figlet
            ctl
          ];
        };
      homeConfigurations = {
        "me@licious" = callPackage ./hosts/licious/home.nix {
          name = "licious";
          home-manager = inputs.home-manager;
        };
        "me@expert" = callPackage ./hosts/expert/home.nix {
          name = "expert";
          home-manager = inputs.home-manager;
        };
      };
      nixosConfigurations = {
        licious =
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                rocmSupport = true;
              };
            };
            unstablepkgs = import inputs.nixpkgs-unstable {
              inherit system;
              # https://github.com/NixOS/nixpkgs/issues/379354
              # Note, unable to build open-webui as pytorch being marked as
              # borken when building with rocm support.
              config = {
                rocmSupport = true;
              };
            };
            mypkgs = pkgs.callPackage ./pkgs {
              config = {
                rocmSupport = true;
              };
            };
            callPackage = pkgs.lib.callPackageWith {
              inherit pkgs;
              inherit unstablepkgs;
              inherit mypkgs;
            };
          in
          callPackage ./hosts/licious/system.nix {
            inherit system;
            nixpkgs = inputs.nixpkgs;
          };
        expert = callPackage ./hosts/expert/system.nix {
          inherit system;
          nixpkgs = inputs.nixpkgs;
        };
      };
    };
}
