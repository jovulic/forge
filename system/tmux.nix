{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.tmux;
in
with lib;
{
  options = {
    forge.system.tmux = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable tmux configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.tmux
    ];
  };
}
