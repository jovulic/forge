{
  config,
  pkgs,
  lib,
  mypkgs,
  ...
}:
let
  cfg = config.forge.system.lllm;
  llama-server = lib.getExe' cfg.package "llama-server";

  llama-load = pkgs.writeShellApplication {
    name = "llama-load";
    runtimeInputs = [
      cfg.package
    ];
    text = builtins.readFile ./llama-load.sh;
    bashOptions = [
      "errexit"
      "pipefail"
    ];
  };
in
with lib;
{
  options = {
    forge.system.lllm = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable lllm \"Local LLM\" configuration with llama-swap.";
      };
      package = mkOption {
        type = types.package;
        default = pkgs.llama-cpp;
        description = "The llama-cpp package containing llama-server.";
      };
    };
  };
  config = mkIf cfg.enable {
    services.llama-swap = {
      enable = true;
      port = 8081;

      settings = {
        healthCheckTimeout = 120; # 2 minutes
        logLevel = "info";

        models = {
          "gemma4-9b" = {
            cmd = "${llama-server} --port \${PORT} -hf bartowski/google_gemma-4-E4B-it-GGUF:Q4_K_M -ngl 99 --no-webui";
            aliases = [
              "gemma4"
              "default"
            ];
          };

          "gemma4-12b" = {
            cmd = "${llama-server} --port \${PORT} -hf bartowski/gemma-4-12B-it-GGUF:Q4_K_M -ngl 99 --no-webui";
          };

          "gemma4-26b" = {
            cmd = "${llama-server} --port \${PORT} -hf bartowski/google_gemma-4-26B-A4B-it-GGUF:Q4_K_M -ngl 99 --no-webui";
          };
        };
      };
    };

    systemd.services.llama-swap = {
      environment = {
        HSA_OVERRIDE_GFX_VERSION = "10.3.0"; # RX 6800 compatibility
        HF_HOME = "/var/cache/llama/huggingface";
        LLAMA_CACHE = "/var/cache/llama/llama.cpp"; # writable local cache for metadata
      };
      serviceConfig = {
        CacheDirectory = "llama";
        SupplementaryGroups = [
          "video"
          "render"
        ];
        ProcSubset = lib.mkForce "all"; # allow reading /proc/meminfo for system stats
      };
    };

    environment.systemPackages = [
      pkgs.rocmPackages.rocminfo
      pkgs.rocmPackages.rocm-smi
      cfg.package
      llama-load

      mypkgs.mcp-hub
    ];
  };
}
