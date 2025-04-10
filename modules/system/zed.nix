{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.zed;
in
with lib;
{
  options = {
    forge.system.zed = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable zed configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.zed-editor
    ];
  };
}
