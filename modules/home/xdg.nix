{
  config,
  lib,
  ...
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
        desktop = "$HOME/desktop";
        documents = "$HOME/documents";
        download = "$HOME/downloads";
        music = "$HOME/music";
        pictures = "$HOME/pictures";
        publicShare = "$HOME/public";
        templates = "$HOME/templates";
        videos = "$HOME/videos";
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
          "application/json" = [ "nvim-custom.desktop" ];
          "application/octet-stream" = [ "nvim-custom.desktop" ];
          "application/pdf" = [ "org.pwmt.zathura.desktop" ];
          "image/gif" = [ "imv.desktop" ];
          "image/jpeg" = [ "imv.desktop" ];
          "image/png" = [ "imv.desktop" ];
          "image/svg+xml" = [ "imv.desktop" ];
          "image/tiff" = [ "imv.desktop" ];
          "image/webp" = [ "imv.desktop" ];
          "text/css" = [ "nvim-custom.desktop" ];
          "text/csv" = [ "nvim-custom.desktop" ];
          "text/html" = [ "nvim-custom.desktop" ];
          "text/javascript" = [ "nvim-custom.desktop" ];
          "text/plain" = [ "nvim-custom.desktop" ];
          "text/yaml" = [ "nvim-custom.desktop" ];
          "video/mp2t" = [ "vlc.desktop" ];
          "video/mp4" = [ "vlc.desktop" ];
          "video/mpeg" = [ "vlc.desktop" ];
          "video/ogg" = [ "vlc.desktop" ];
          "video/webm" = [ "vlc.desktop" ];
          "video/x-msvideo" = [ "vlc.desktop" ];
        };
      };
      desktopEntries = {
        "nvim-custom" = {
          name = "nvim-custom";
          genericName = "Text Editor";
          comment = "Edit text files";
          exec = "foot -e nvim %F";
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
