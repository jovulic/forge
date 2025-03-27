{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.nixpkgs;
in
with lib;
{
  options = {
    forge.system.nixpkgs = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable nixpkgs configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    nixpkgs = {
      config = {
        allowUnfreePredicate =
          (
            lib: pkg:
            builtins.elem (lib.getName pkg) [
              "discord"
              "google-chrome"
              "via"
              "steam"
              "steam-original"
              "steam-run"
              "steam-unwrapped"
              "obsidian"
            ]
          )
            lib;
        permittedInsecurePackages = [ ];
      };
    };
  };
}
