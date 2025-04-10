{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.nix-index;
in
with lib;
{
  options = {
    forge.system.nix-index = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable nix-index configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.nix-index = {
      enable = true;
    };

    programs.command-not-found.enable = false;
  };
}
