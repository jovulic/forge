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
    ];
  };
}
