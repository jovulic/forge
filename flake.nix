{
  description = "Where I shape my machines.";

  inputs = {
    flake-parts.url = "github:hercules-ci/flake-parts";
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

  outputs = inputs@{ flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      perSystem = { config, pkgs, system, ... }: {
        devShells.default =
          let
            ctl = pkgs.writeShellApplication {
              name = "ctl";
              runtimeInputs = [ pkgs.figlet ];
              text = builtins.readFile ./ctl/ctl;
              bashOptions = [ "errexit" "pipefail" ];
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
      };

      flake =
        let
          # Helper for creating our custom callPackage logic based on standard instantiation
          mkCallPackage = system:
            let
              pkgs = import inputs.nixpkgs { inherit system; };
              unstablepkgs = import inputs.nixpkgs-unstable {
                inherit system;
                config.allowUnfree = true;
              };
              mypkgs = pkgs.callPackage ./pkgs { };
            in
            pkgs.lib.callPackageWith {
              inherit pkgs unstablepkgs mypkgs;
            };

          callPackageLinux = mkCallPackage "x86_64-linux";
          callPackageDarwin = mkCallPackage "aarch64-darwin";
        in
        {
          homeConfigurations = {
            "me@licious" = callPackageLinux ./hosts/licious/home.nix {
              name = "licious";
              home-manager = inputs.home-manager;
              chaotic = inputs.chaotic;
            };
            "me@expert" = callPackageLinux ./hosts/expert/home.nix {
              name = "expert";
              home-manager = inputs.home-manager;
              chaotic = inputs.chaotic;
            };
          };

          nixosConfigurations = {
            licious =
              let
                system = "x86_64-linux";
                pkgs = import inputs.nixpkgs {
                  inherit system;
                  config = { rocmSupport = true; };
                };
                unstablepkgs = import inputs.nixpkgs-unstable {
                  inherit system;
                  config = {
                    allowUnfree = true;
                    rocmSupport = true;
                  };
                };
                mypkgs = pkgs.callPackage ./pkgs {
                  config = { rocmSupport = true; };
                };
                callPackage = pkgs.lib.callPackageWith {
                  inherit pkgs unstablepkgs mypkgs;
                };
              in
              callPackage ./hosts/licious/system.nix {
                inherit system;
                nixpkgs = inputs.nixpkgs;
                lanzaboote = inputs.lanzaboote;
                chaotic = inputs.chaotic;
              };

            expert = callPackageLinux ./hosts/expert/system.nix {
              system = "x86_64-linux";
              nixpkgs = inputs.nixpkgs;
              chaotic = inputs.chaotic;
            };

            test = callPackageLinux ./hosts/test/system.nix {
              system = "x86_64-linux";
              nixpkgs = inputs.nixpkgs;
              chaotic = inputs.chaotic;
            };
          };

          darwinConfigurations = {
            apple = callPackageDarwin ./hosts/apple/system.nix {
              inherit (inputs) nix-darwin home-manager;
              system = "aarch64-darwin";
            };
          };
        };
    };
}