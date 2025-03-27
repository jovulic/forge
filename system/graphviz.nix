{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.graphviz;
in
with lib;
{
  options = {
    forge.system.graphviz = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable graphviz configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.graphviz
    ];
  };
}
