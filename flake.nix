{
  description = "Where I shape my machines.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-26.05";
    nix-darwin = {
      url = "github:LnL7/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    lanzaboote = {
      url = "github:nix-community/lanzaboote/v0.4.3";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
    chaotic = {
      url = "github:chaotic-cx/nyx/nyxpkgs-unstable";
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
        config.allowUnfree = true;
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
            pkgs.bash # added so bash works within direnv
          ];
        };
      homeConfigurations = {
        "me@licious" = callPackage ./hosts/licious/home.nix {
          name = "licious";
          home-manager = inputs.home-manager;
          chaotic = inputs.chaotic;
        };
        "me@expert" = callPackage ./hosts/expert/home.nix {
          name = "expert";
          home-manager = inputs.home-manager;
          chaotic = inputs.chaotic;
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
              config = {
                allowUnfree = true;
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
            lanzaboote = inputs.lanzaboote;
            chaotic = inputs.chaotic;
          };
        expert = callPackage ./hosts/expert/system.nix {
          inherit system;
          nixpkgs = inputs.nixpkgs;
          chaotic = inputs.chaotic;
        };
        test = callPackage ./hosts/test/system.nix {
          inherit system;
          nixpkgs = inputs.nixpkgs;
          chaotic = inputs.chaotic;
        };
      };
      darwinConfigurations = {
        macbook =
          let
            darwinSystem = "aarch64-darwin";
            pkgs = import inputs.nixpkgs {
              system = darwinSystem;
            };
            unstablepkgs = import inputs.nixpkgs-unstable {
              system = darwinSystem;
              config.allowUnfree = true;
            };
            mypkgs = pkgs.callPackage ./pkgs { };
          in
          inputs.nix-darwin.lib.darwinSystem {
            system = darwinSystem;
            modules = [
              ./hosts/macbook/system.nix
              inputs.home-manager.darwinModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit unstablepkgs mypkgs;
                    chaotic = null;
                  };
                  users.josipvulic = import ./hosts/macbook/home.nix;
                };
              }
            ];
          };
      };
    };
}
