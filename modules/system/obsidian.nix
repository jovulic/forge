{
  config,
  lib,
  unstablepkgs,
  ...
}:
let
  cfg = config.forge.system.obsidian;
in
with lib;
{
  options = {
    forge.system.obsidian = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable obsidian configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      unstablepkgs.obsidian
    ];
  };
}
