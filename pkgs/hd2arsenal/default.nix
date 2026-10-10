{
  lib,
  appimageTools,
  requireFile,
}:
let
  pname = "hd2arsenal";
  version = "0.36.2";

  src = requireFile {
    name = "HD2Arsenal-${version}.AppImage";
    hash = "sha256-xWJiuQr9Tsw5nRTP6QPrd4WlL4An+QqFQy6OvYK28tA=";
    message = ''
      HD2 Arsenal cannot be downloaded automatically due to Nexus Mods authentication.

      1. Download HD2 Arsenal for Linux from: https://rsnl.gg/downloads/linux
      2. If downloaded as a .zip, extract 'HD2Arsenal-${version}.AppImage'.
      3. Add it to the Nix store using:
         nix-prefetch-url file:///path/to/HD2Arsenal-${version}.AppImage
    '';
  };

  appimageContents = appimageTools.extractType2 {
    inherit pname version src;
  };
in
appimageTools.wrapType2 {
  inherit pname version src;

  extraInstallCommands = ''
    install -m 444 -D ${appimageContents}/hd2arsenal.desktop $out/share/applications/hd2arsenal.desktop
    substituteInPlace $out/share/applications/hd2arsenal.desktop \
      --replace-fail "Exec=AppRun --no-sandbox %U" "Exec=hd2arsenal %U" \
      --replace-fail "MimeType=x-scheme-handler/nxm;application/x-hd2a-project;x-scheme-handler/nxm;" "MimeType=x-scheme-handler/nxm;x-scheme-handler/rsnl;application/x-hd2a-project;"

    for size in 16 32 48 64 128 256 512; do
      if [ -f "${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/hd2arsenal.png" ]; then
        install -m 444 -D "${appimageContents}/usr/share/icons/hicolor/''${size}x''${size}/apps/hd2arsenal.png" \
          "$out/share/icons/hicolor/''${size}x''${size}/apps/hd2arsenal.png"
      fi
    done
  '';

  meta = with lib; {
    description = "Helldivers 2 Companion Desktop Application and Mod Manager (Arsenal)";
    homepage = "https://rsnl.gg/";
    license = licenses.unfree;
    platforms = [ "x86_64-linux" ];
    mainProgram = "hd2arsenal";
  };
}
