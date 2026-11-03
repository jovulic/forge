{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.lllm;
in
with lib;
{
  options = {
    forge.home.lllm = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable lllm configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file.".config/opencode/opencode.json.template".text = builtins.toJSON {
      "$schema" = "https://opencode.ai/config.json";
      provider = {
        "llama-swap" = {
          npm = "@ai-sdk/openai-compatible";
          name = "llama-swap";
          options = {
            baseURL = "http://127.0.0.1:11434/v1";
          };
          models = {
            "gemma4:2b" = {
              name = "gemma4:2b";
            };
            "gemma4:9b" = {
              name = "gemma4:9b";
            };
            "gemma4:12b" = {
              name = "gemma4:12b";
            };
            "gemma4:26b" = {
              name = "gemma4:26b";
            };
          };
        };
      };
      model = "llama-swap/gemma4:9b";
    };

    home.activation.applyOpencodeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
      mkdir -p "$HOME/.config/opencode"
      TEMPLATE="$HOME/.config/opencode/opencode.json.template"
      TARGET="$HOME/.config/opencode/opencode.json"
      if [ ! -f "$TARGET" ]; then
        cp -f "$TEMPLATE" "$TARGET"
        chmod 644 "$TARGET"
      fi
    '';
  };
}
