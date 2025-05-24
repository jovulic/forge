{ pkgs, ... }:
{
  # Manix overlay necessary in order for it to work with home-manager options
  # when it has only been configured via flakes.
  # https://github.com/nix-community/manix/issues/18
  nixpkgs.overlays = [
    (self: super: {
      manix = super.manix.override (old: {
        rustPlatform = old.rustPlatform // {
          buildRustPackage =
            args:
            old.rustPlatform.buildRustPackage (
              args
              // {
                version = "0.8.0-pr20";
                src = super.fetchFromGitHub {
                  owner = "nix-community";
                  repo = "manix";
                  rev = "c532d14b0b59d92c4fab156fc8acd0565a0836af";
                  sha256 = "sha256-Uo+4/be6rT0W8Z1dvCRXOANvoct6gJ4714flhyFzmKU=";
                };
                cargoHash = "sha256-FTrKdOuXTOqr7on4RzYl/UxgUJqh+Rk3KJXqsW0fuo0=";
              }
            );
        };
      });
    })
  ];
  environment.systemPackages = [
    pkgs.nix-search-cli
    pkgs.manix
    (pkgs.writeShellApplication {
      name = "forge";
      runtimeInputs = [
        pkgs.nix-search-cli
        pkgs.manix
        pkgs.fzf
      ];
      text = builtins.readFile ./forge.sh;
      bashOptions = [
        "errexit"
        "pipefail"
      ];
    })
  ];
}
