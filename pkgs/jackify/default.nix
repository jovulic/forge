{ pkgs, ... }:

pkgs.appimageTools.wrapType2 {
  pname = "jackify";
  version = "0.8.0";

  src = pkgs.fetchurl {
    url = "https://github.com/Omni-guides/Jackify/releases/download/v0.8.0/Jackify.AppImage";
    hash = "sha256-NZWeoijFAl4xVoF7Gl7TRx3DTxcb6fTk4KFjFdRCt5o=";
  };

  extraPkgs = pkgs: with pkgs; [
    xcbutilcursor
    zstd
  ];

  meta = {
    description = "Linux application for installing and configuring Wabbajack modlists on Linux and Steam Deck";
    homepage = "https://github.com/Omni-guides/Jackify";
    license = pkgs.lib.licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
  };
}
