{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.torrent;
in
with lib;
{
  options = {
    forge.system.torrent = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable torrent configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.qbittorrent
    ];
  };
}
