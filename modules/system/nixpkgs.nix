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
              "ventoy"
              "rar"
              "unrar"
              "open-webui"
            ]
          )
            lib;
        permittedInsecurePackages = [
          # - Ventoy uses binary blobs which can't be trusted to be free of malware or compliant to their licenses.
          # https://github.com/NixOS/nixpkgs/issues/404663
          #
          # See the following Issues for context:
          # https://github.com/ventoy/Ventoy/issues/2795
          # https://github.com/ventoy/Ventoy/issues/3224
          "ventoy-1.1.05"
        ];
      };
    };
  };
}
