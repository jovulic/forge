{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.screengrab;
in
with lib;
{
  options = {
    forge.system.screengrab = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable screen grab (video recording) configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.slurp
      pkgs.wf-recorder
      pkgs.libnotify
      (pkgs.writeShellScriptBin "dscreengrab" (builtins.readFile ./screengrab.sh))
    ];
  };
}
