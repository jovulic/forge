{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.ranger;
in
with lib;
{
  options = {
    forge.system.ranger = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable ranger configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.ranger
      pkgs.file # for determining file types
      pkgs.w3m # for image perviews
      pkgs.mpv # for image previews
      pkgs.imagemagick # to auto-rotate images and for image previews
      pkgs.librsvg # for SVG previews
      pkgs.ffmpeg # for video thumbnails
      pkgs.ffmpegthumbnailer # for video thumbnails
      pkgs.bat # for code highlighting
      pkgs.atool # to preview archives
      pkgs.libarchive # to preview archives as their first image
      pkgs.mediainfo # for viewing information about media files
      pkgs.jq # for JSON files
      pkgs.poppler_utils # for PDF files
    ];
  };
}
