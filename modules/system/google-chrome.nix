{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.google-chrome;
in
with lib;
{
  options = {
    forge.system.google-chrome = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable google-chrome configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.google-chrome
      # https://bugs.chromium.org/p/chromium/issues/detail?id=1042393
      (pkgs.writeShellScriptBin "google-chrome-custom" ''
        google-chrome-stable --enable-logging --v=1 --use-gl=desktop --disable-gpu-driver-bug-workarounds
      '')
      (pkgs.writeShellScriptBin "google-chrome-mcp" ''
        exec google-chrome-stable \
          --remote-debugging-port=9222 \
          --user-data-dir="$HOME/.config/google-chrome-mcp" \
          --no-first-run \
          --no-default-browser-check \
          "$@"
      '')
    ];
  };
}
