{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.vr;
in
with lib;
{
  options = {
    forge.home.vr = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable home-manager VR configuration.";
      };

      backend = mkOption {
        type = types.enum [
          "alvr"
          "wivrn"
        ];
        default = "wivrn";
        description = "Which VR backend to configure.";
      };
    };
  };

  config = mkIf cfg.enable (mkMerge [
    (mkIf (cfg.backend == "wivrn") {
      home.file.".local/share/openvr/openvrpaths.vrpath" = {
        text = builtins.toJSON {
          config = [
            "${config.home.homeDirectory}/.local/share/Steam/config"
          ];
          external_drivers = null;
          log = [
            "${config.home.homeDirectory}/.local/share/Steam/logs"
          ];
          runtime = [
            "/run/current-system/sw/lib/xrizer"
          ];
        };
      };
    })
  ]);
}
