{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.tex;
in
with lib;
{
  options = {
    forge.system.tex = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable tex configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.texlive.combined.scheme-full
    ];
  };
}
