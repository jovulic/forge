{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.gopass;
in
with lib;
{
  options = {
    forge.system.gopass = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gopass configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.gopass
      (pkgs.writeShellScriptBin "dgopass" ''
        gopass ls --flat | bemenu | xargs --no-run-if-empty gopass show --alsoclip
      '')
    ];
    # $ gopass clone --check-keys=false $repository_git_url
    # $ gopass clone --check-keys=false $repository_git_url $target
  };
}
