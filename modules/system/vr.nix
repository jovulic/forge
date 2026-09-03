{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.vr;
in
with lib;
{
  options = {
    forge.system.vr = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable VR configuration.";
      };

      backend = mkOption {
        type = types.enum [ "alvr" "wivrn" ];
        default = "wivrn";
        description = "Which VR backend to use.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.backend == "alvr") {
      programs.alvr = {
        enable = true;
        openFirewall = true;
      };
    })

    (mkIf (cfg.backend == "wivrn") {
      services.wivrn = {
        enable = true;
        openFirewall = true;
        highPriority = true;
        steam.importOXRRuntimes = true;
      };
    })
  ]);
}
