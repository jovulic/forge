{
  config,
  pkgs,
  lib,
  mypkgs,
  ...
}:
let
  cfg = config.forge.system.lllm;
in
with lib;
{
  options = {
    forge.system.lllm = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable lllm \"Local LLM\" configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # let
    #   ollama = unstablepkgs.ollama.overrideAttrs (oldAttrs: {
    #     version = "0.11.2";
    #     src = oldAttrs.src.override {
    #       hash = "sha256-NZaaCR6nD6YypelnlocPn/43tpUz0FMziAlPvsdCb44=";
    #     };
    #     vendorHash = "sha256-SlaDsu001TUW+t9WRp7LqxUSQSGDF1Lqu9M1bgILoX4=";
    #   });
    # in
    services.ollama = {
      enable = true;
      acceleration = "rocm";
      rocmOverrideGfx = "10.3.0"; # gfx1030
    };

    services.open-webui = {
      enable = true;
      port = 8081;
      environment = {
        FRONTEND_BUILD_DIR = "${config.services.open-webui.stateDir}/build";
        DATA_DIR = "${config.services.open-webui.stateDir}/data";
        STATIC_DIR = "${config.services.open-webui.stateDir}/static";
        WEBUI_AUTH = "False";
      };
    };

    environment.systemPackages = [
      pkgs.rocmPackages.rocminfo
      pkgs.rocmPackages.rocm-smi

      mypkgs.mcp-hub
    ];
  };
}
