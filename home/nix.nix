{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.nix;
in
with lib;
{
  options = {
    forge.home.nix = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable nix configuration.";
      };
      package = mkPackageOption pkgs "nix" { };
    };
  };
  config = mkIf cfg.enable {
    nix = {
      package = cfg.package;
    };
  };
}
