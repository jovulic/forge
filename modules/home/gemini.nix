{
  config,
  lib,
  pkgs,
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
        SANDBOX_FLAGS="--network=pasta:-T,37373 --userns=keep-id --user 1000:100"
      '';
    };

    home.activation.applyGeminiSettingsOverlay = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      # Ensure config directory exists.
      mkdir -p "$HOME/.gemini"

      SETTINGS_FILE="$HOME/.gemini/settings.json"

      # If settings.json is a symlink, delete it and initialize it as a regular file.
      if [ -L "$SETTINGS_FILE" ]; then
        rm "$SETTINGS_FILE"
      fi

      # If settings.json doesn't exist, initialize it as empty JSON.
      if [ ! -f "$SETTINGS_FILE" ]; then
        echo "{}" > "$SETTINGS_FILE"
      fi

      # Define the overlay settings JSON with low-flicker optimizations and core repo settings.
      OVERLAY='{
        "ui": {
          "useAlternateBuffer": true,
          "incrementalRendering": true,
          "terminalBuffer": true
        },
        "general": {
          "disableAutoUpdate": true
        },
        "context": {
          "fileName": ["AGENTS.md", "GEMINI.md"]
        }
      }'

      # Merge overlay with existing settings using jq.
      TEMP_FILE=$(mktemp)
      ${pkgs.jq}/bin/jq \
        --argjson overlay "$OVERLAY" \
        '.ui = (.ui // {}) + $overlay.ui | .general = (.general // {}) + $overlay.general | .context = (.context // {}) + $overlay.context' \
        "$SETTINGS_FILE" > "$TEMP_FILE"

      mv "$TEMP_FILE" "$SETTINGS_FILE"
      chmod 644 "$SETTINGS_FILE"
    '';
  };
}
