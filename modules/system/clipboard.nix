{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.clipboard;
in
with lib;
{
  options = {
    forge.system.clipboard = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable clipboard configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.wl-clipboard
      pkgs.clipman
      (pkgs.writeShellScriptBin "dclipboard" ''
        clipman pick --max-items=10 -t bemenu
      '')
    ];
  };
}
