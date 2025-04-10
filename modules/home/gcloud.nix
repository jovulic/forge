{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.gcloud;
in
with lib;
{
  options = {
    forge.home.gcloud = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gcloud configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.sessionVariables = {
      GOOGLE_APPLICATION_CREDENTIALS = "$HOME/.config/gcloud/application_default_credentials.json";
    };
  };
}
