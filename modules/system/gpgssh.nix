{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.gpgssh;
in
with lib;
{
  options = {
    forge.system.gpgssh = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gpgssh configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.pinentry-qt
      (pkgs.writeShellScriptBin "gpglb" ''
        gpg --pinentry-mode loopback $@
      '')
    ];
    programs.gnupg = {
      agent = {
        enable = true;
        enableSSHSupport = true;
      };
    };
  };
}
