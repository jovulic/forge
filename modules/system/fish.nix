{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.fish;
in
with lib;
{
  options = {
    forge.system.fish = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable fish configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.fzf # for fzf.fish
      pkgs.fd # for fzf.fish
      pkgs.bat # for fzf.fish
    ];
    programs.fish = {
      enable = true;
    };
  };
}
