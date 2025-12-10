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
        SANDBOX_FLAGS="--network=pasta:-T,3000 --userns=keep-id"
      '';
    };
  };
}
