{
  config,
  pkgs,
  unstablepkgs,
  lib,
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
    services.ollama = {
      package = unstablepkgs.ollama;
      enable = true;
      acceleration = "rocm";
      rocmOverrideGfx = "10.3.0"; # gfx1030
    };

    services.open-webui = {
      # package = unstablepkgs.open-webui;
      enable = true;
      port = 8081;
      environment = {
        WEBUI_AUTH = "False";
      };
    };

    environment.systemPackages = [
      pkgs.rocmPackages.rocminfo
      pkgs.rocmPackages.rocm-smi
    ];
  };
}
