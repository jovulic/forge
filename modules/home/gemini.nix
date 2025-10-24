{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.gemini;
in
with lib;
{
  options = {
    forge.home.gemini = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gemini configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file.".gemini/.env" = {
      text = ''
        GOOGLE_CLOUD_PROJECT="gemini-107679"
      '';
    };
  };
}
