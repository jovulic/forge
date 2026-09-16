{
  config,
  lib,
  pkgs,
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

    home.activation.applyOpencodeSettings = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
      mkdir -p "$HOME/.config/opencode"
      TEMPLATE="$HOME/.config/opencode/opencode.json.template"
      TARGET="$HOME/.config/opencode/opencode.json"
      if [ ! -f "$TARGET" ]; then
        cp -f "$TEMPLATE" "$TARGET"
        chmod 644 "$TARGET"
      fi
    '';

    home.file.".config/mcphub/mcp_settings.json.template" = {
      text = builtins.toJSON {
        mcpServers = {
          chrome-devtools = {
            command = "npx";
            args = [
              "-y"
              "chrome-devtools-mcp"
              "--browserUrl=http://127.0.0.1:9222"
            ];
          };
        };
        systemConfig = {
          routing = {
            sessionRebuild = true;
          };
        };
      };
    };

    systemd.user.services = {
      mcphub = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "MCP Hub Server";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStartPre = [
            "${pkgs.podman}/bin/podman rm -f mcphub"
            "${pkgs.coreutils}/bin/mkdir -p %h/.config/mcphub/data"
            "${pkgs.writeShellScript "mcphub-prep" ''
              TEMPLATE="$HOME/.config/mcphub/mcp_settings.json.template"
              TARGET="$HOME/.config/mcphub/mcp_settings.json"
              if [ ! -f "$TARGET" ]; then
                cp -f "$TEMPLATE" "$TARGET"
                chmod 644 "$TARGET"
              fi
            ''}"
          ];
          ExecStart = concatStringsSep " " [
            "${pkgs.podman}/bin/podman run"
            "--name mcphub"
            "--network=host"
            "-v %h/.config/mcphub/mcp_settings.json:/app/mcp_settings.json"
            "-v %h/.config/mcphub/data:/app/data"
            "-e ADMIN_PASSWORD=admin"
            "docker.io/samanhappy/mcphub:latest"
          ];
          ExecStop = "${pkgs.podman}/bin/podman stop mcphub";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };

    # MANUAL (mcphub):
    # - Disable dashboard login: security -> skip authentication.
    # - Disable endpoint authentication: keys -> enable bearer authentication.
  };
}
