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
    /*
      ~/.gemini/settings.json
      {
        "security": {
          "auth": {
            "selectedType": "oauth-personal"
          }
        },
        "ui": {
          "theme": "Default"
        },
        "general": {
          "disableAutoUpdate": true
        },
        "context": {
          "fileName": ["AGENTS.md", "GEMINI.md"]
        },
        "mcpServers": {
          "Hub": {
            "url": "http://localhost:3000/mcp"
          }
        }
      }
    */
    home.file.".gemini/.env" = {
      text = ''
        GOOGLE_CLOUD_PROJECT="gemini-107679"
        SANDBOX_FLAGS="--network=pasta:-T,3000"
      '';
    };
    # NOTE: If running in sandbox mode, and it keeps requiring re-auth, relax
    # the permission on oauth_creds.json as the user mappings are likely
    # getting in the way.
    # Change with...
    # chmod 644 ~/.gemini/oauth_creds.json
    # You can revert  with...
    # chmod 600 ~/.gemini/oauth_creds.json
  };
}
