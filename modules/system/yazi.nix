{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.yazi;
in
with lib;
{
  options = {
    forge.system.yazi = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable yazi modern terminal file manager.";
      };
    };
  };

  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.yazi
      pkgs.file # for determining file types
      pkgs.ffmpegthumbnailer # for video thumbnails
      pkgs.unar # for archive previewing
      pkgs.jq # for json previewing
      pkgs.poppler-utils # for pdf previewing
      pkgs.fd # fast search
      pkgs.ripgrep # fast search within files
      pkgs.fzf # fuzzy finder
      pkgs.zoxide # smart directory jumping
    ];
  };
}
