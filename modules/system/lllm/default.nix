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
            # NOTE: --no-mmproj is a temporary workaround because llama-server
            # cannot yet parse the new unified 'gemma4uv' multimodal projector.
            cmd = "${llama-server} --port \${PORT} -hf bartowski/gemma-4-12B-it-GGUF:Q4_K_M -ngl 99 --no-webui --no-mmproj";
          };

          "gemma4-26b" = {
            # NOTE: Hybrid GPU+CPU Offloading: Gemma 4 26B has 30 hidden
            # layers. Offloading all layers to a 16GB GPU (like the RX 6800)
            # causes CUDA OOM crashes due to weight size and context overhead.
            # We configure a generous 64k context (-c 65536) and perform hybrid
            # offloading (-ngl 18 out of 30 layers). This allows the active
            # context and weights to load perfectly, spilling over to your 64GB
            # system RAM cleanly.
            #
            # NOTE: --no-mmproj is a temporary workaround because llama-server
            # cannot yet parse the new unified 'gemma4uv' multimodal projector.
            cmd = "${llama-server} --port \${PORT} -hf bartowski/google_gemma-4-26B-A4B-it-GGUF:Q4_K_M -ngl 18 -c 65536 --no-webui --no-mmproj";
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
