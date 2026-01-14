{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.nix;
in
with lib;
{
  options = {
    forge.system.nix = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable nix configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    nix = {
      extraOptions = ''
        experimental-features = nix-command flakes
      '';
      settings = {
        # Allows derivations to break the sandbox by setting "__noChroot = true;".
        sandbox = "relaxed";
        # I believe the following came about when trying to break the
        # sandbox. Prior to the relaxed option, trusted users would need to
        # be specified, and only those users could break the sandbox via
        # "option sandbox false".
        trusted-users = [
          "root"
          "@wheel"
        ];
      };
    };

    programs.nh = {
      # source: https://github.com/NixOS/nixpkgs/blob/nixos-25.11/pkgs/by-name/nh/nh/package.nix#L74
      package = pkgs.nh.overrideAttrs (final: rec {
        version = "af45145463dd47d40ea5868bd759546e4fc5adbd";
        src = pkgs.fetchFromGitHub {
          owner = "jovulic";
          repo = "nh";
          rev = version;
          hash = "sha256-CViR0PII1XjSjCePQtuZ0Q1d1NqDv+Za1kOZtAu0R4o=";
        };
        patches = [ ];
        cargoDeps = pkgs.rustPlatform.fetchCargoVendor {
          name = "${final.pname}-${version}";
          inherit src;
          hash = "sha256-V+Udw9u8PRl3fE/ZFO0zVlrtHC+vXHNAp5pt4QbFVKA=";
        };
        postInstall = ''
          mkdir -p completions

          # Generate completions for shell.
          for shell in bash zsh fish; do
            cargo xtask completions --out-dir completions $shell
          done

          # Install the generated files.
          installShellCompletion completions/*

          # Generate and install man pages.
          cargo xtask man --out-dir gen
          installManPage gen/nh.1
        '';
        env.NH_REV = version;
      });
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-one --keep-since 3d --keep 3";
        dates = "weekly";
      };
    };

    environment.systemPackages = [
      pkgs.nixpkgs-fmt
    ];
  };
}
