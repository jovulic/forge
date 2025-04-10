{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.git;
in
with lib;
{
  options = {
    forge.system.git = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable git configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.git
      pkgs.git-crypt
      pkgs.gh # github commandline tool
    ];
  };
}
