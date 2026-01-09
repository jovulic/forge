{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.forge.home.kanata;
in
with lib;
{
  options = {
    forge.home.kanata = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kanata configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      ".config/kanata/config-kcd2.kbd" = {
        source = ./kcd2.kbd;
      };
    };

    home.packages = [
      (pkgs.writeShellScriptBin "kanata-kcd2" ''
        sudo kanata --cfg ~/.config/kanata/config-kcd2.kbd
      '')
    ];
  };
}
