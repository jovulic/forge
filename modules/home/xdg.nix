{ config
, lib
, ...
}:
let
  cfg = config.forge.home.xdg;
in
with lib;
{
  options = {
    forge.home.xdg = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable xdg configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    xdg = {
      enable = true;
      userDirs = {
        enable = true;
        createDirectories = true;
        setSessionVariables = false;
        desktop = "$HOME/desktop";
        documents = "$HOME/documents";
        download = "$HOME/downloads";
        music = "$HOME/music";
        pictures = "$HOME/pictures";
        publicShare = "$HOME/public";
        templates = "$HOME/templates";
        videos = "$HOME/videos";
        projects = null;
      };
      mime = {
        enable = true;
      };
      mimeApps = {
        enable = true;
        defaultApplications = {
          "x-www-browser" = [ "google-chrome.desktop" ];
          "x-scheme-handler/http" = [ "google-chrome.desktop" ];
          "x-scheme-handler/https" = [ "google-chrome.desktop" ];
          "x-scheme-handler/about" = [ "google-chrome.desktop" ];
          "x-scheme-handler/unknown" = [ "google-chrome.desktop" ];
          "x-scheme-handler/element" = [ "element-desktop.desktop" ];

          "inode/directory" = [ "nemo.desktop" ];

          "application/x-bittorrent" = [ "org.qbittorrent.qBittorrent.desktop" ];
          "x-scheme-handler/magnet" = [ "org.qbittorrent.qBittorrent.desktop" ];

          "application/json" = [
            "nvim-custom.desktop"
            "dev.zed.Zed.desktop"
          ];
          "application/octet-stream" = [ "nvim-custom.desktop" ];
          "text/css" = [
            "nvim-custom.desktop"
            "dev.zed.Zed.desktop"
          ];
          "text/csv" = [ "nvim-custom.desktop" ];
          "text/html" = [
            "nvim-custom.desktop"
            "google-chrome.desktop"
          ];
          "text/javascript" = [
            "nvim-custom.desktop"
            "dev.zed.Zed.desktop"
          ];
          "text/plain" = [
            "nvim-custom.desktop"
            "dev.zed.Zed.desktop"
          ];
          "text/yaml" = [
            "nvim-custom.desktop"
            "dev.zed.Zed.desktop"
          ];
          "text/markdown" = [
            "nvim-custom.desktop"
            "dev.zed.Zed.desktop"
            "obsidian.desktop"
          ];

          "application/pdf" = [ "org.pwmt.zathura.desktop" ];

          "image/gif" = [ "imv.desktop" ];
          "image/jpeg" = [ "imv.desktop" ];
          "image/png" = [ "imv.desktop" ];
          "image/svg+xml" = [ "imv.desktop" ];
          "image/tiff" = [ "imv.desktop" ];
          "image/webp" = [ "imv.desktop" ];

          "video/mp2t" = [
            "mpv.desktop"
            "vlc.desktop"
          ];
          "video/mp4" = [
            "mpv.desktop"
            "vlc.desktop"
          ];
          "video/mpeg" = [
            "mpv.desktop"
            "vlc.desktop"
          ];
          "video/ogg" = [
            "mpv.desktop"
            "vlc.desktop"
          ];
          "video/webm" = [
            "mpv.desktop"
            "vlc.desktop"
          ];
          "video/x-msvideo" = [
            "mpv.desktop"
            "vlc.desktop"
          ];

          "audio/mp3" = [
            "mpv.desktop"
            "vlc.desktop"
          ];
          "audio/mpeg" = [
            "mpv.desktop"
            "vlc.desktop"
          ];
          "audio/ogg" = [
            "mpv.desktop"
            "vlc.desktop"
          ];
          "audio/wav" = [
            "mpv.desktop"
            "vlc.desktop"
          ];
          "audio/x-wav" = [
            "mpv.desktop"
            "vlc.desktop"
          ];
          "audio/flac" = [
            "mpv.desktop"
            "vlc.desktop"
          ];
        };
      };
      desktopEntries = {
        "nvim-custom" = {
          name = "nvim-custom";
          genericName = "Text Editor";
          comment = "Edit text files";
          exec = "${config.forge.home.terminal.name} -e nvim %F";
          terminal = false;
          type = "Application";
          icon = "nvim";
          categories = [
            "Utility"
            "TextEditor"
          ];
          startupNotify = false;
          mimeType = [
            "text/english"
            "text/plain"
            "text/x-makefile"
            "text/x-c++hdr"
            "text/x-c++src"
            "text/x-chdr"
            "text/x-csrc"
            "text/x-java"
            "text/x-moc"
            "text/x-pascal"
            "text/x-tcl"
            "text/x-tex"
            "application/x-shellscript"
            "text/x-c"
            "text/x-c++"
          ];
        };
        "element-desktop" = {
          name = "element-desktop";
          exec = "element-desktop %u";
          genericName = "Matrix Client";
          type = "Application";
          icon = "element";
          comment = "A feature-rich client for Matrix.org";
          categories = [
            "Network"
            "InstantMessaging"
            "Chat"
          ];
          mimeType = [ "x-scheme-handler/element" ];
        };
      };
    };
  };
}
