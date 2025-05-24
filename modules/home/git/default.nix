{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.git;
in
with lib;
{
  options = {
    forge.home.git = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable git configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      ".config/git/config" = {
        source = pkgs.replaceVars ./config {
          delta = "${pkgs.delta}";
          gnupg = "${pkgs.gnupg}";
        };
      };
      ".config/git/config-global" = {
        source = ./config-global;
      };
    };

    programs.lazygit = {
      enable = true;
      settings = {
        git = {
          merging = {
            args = "--no-ff";
          };
        };
      };
    };
  };
}
