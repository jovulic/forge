{
  config,
  lib,
  pkgs,
  mypkgs,
  nix,
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
  config =
    let
      nix-shell-builtin = mypkgs.nix-shell-builtin.override { inherit nix; };
    in
    mkIf cfg.enable {
      nix = {
        package = nix;
        extraOptions = ''
          experimental-features = nix-command flakes
          plugin-files = ${nix-shell-builtin}/lib/nix/plugins/libnix-shell-builtin.so
          enable-shell = true
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

      environment.systemPackages = [
        pkgs.nixpkgs-fmt
      ];
    };
}
