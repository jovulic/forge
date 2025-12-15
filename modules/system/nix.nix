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
      enable = true;
      clean = {
        enable = true;
        extraArgs = "--keep-since 3d --keep 3";
        dates = "weekly";
      };
    };

    environment.systemPackages = [
      pkgs.nixpkgs-fmt
    ];
  };
}
