{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.python;
in
with lib;
{
  options = {
    forge.system.python = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable python configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "python" ''
        export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
        exec ${pkgs.python3}/bin/python "$@"
      '')
      pkgs.uv
    ];
  };
}
