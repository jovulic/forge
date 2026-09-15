{
  lib,
  stdenv,
  fetchFromGitHub,
  rustPlatform,
  pkgsi686Linux,
  python3Packages,
  makeWrapper,
  qt6,
  vulkan-loader,
}:
let
  version = "2.3.1";
  src = fetchFromGitHub {
    owner = "pythonlover02";
    repo = "volt-gui";
    rev = "0c75fc3990babca3985886ca57f120b4fd1bb896";
    hash = "sha256-twW+vFIbOFg8Mpk/z0/ByJXkbwtxetuidrjnSS818uk=";
  };
  cargoHash = "sha256-QsQtiBk0Fl49akEPsRycKqaIzc/Qkj143rCjtxmTER4=";

  # volt-gui's build splits Rust layers/binaries from Python GUI code.
  # We compile 64-bit components and the 32-bit Vulkan layer separately to
  # satisfy both architecture targets for gaming compatibility (e.g. Steam).

  # 64-bit layer, launcher, and probe.
  volt64 = rustPlatform.buildRustPackage {
    pname = "volt-64";
    inherit version src cargoHash;
    doCheck = false;

    installPhase = ''
      runHook preInstall
      mkdir -p $out/bin $out/lib
      install -Dm755 "$(find target -type f -name volt -perm -0100 -print -quit)" $out/bin/volt
      install -Dm755 "$(find target -type f -name volt-probe -perm -0100 -print -quit)" $out/bin/volt-probe
      install -Dm755 "$(find target -type f -name libvolt.so -print -quit)" $out/lib/libvolt.so
      runHook postInstall
    '';
  };

  # 32-bit Vulkan layer (required for 32-bit gaming runtimes).
  volt32 = pkgsi686Linux.rustPlatform.buildRustPackage {
    pname = "volt-layer-32";
    inherit version src cargoHash;
    doCheck = false;
    cargoBuildFlags = [ "--lib" ];

    installPhase = ''
      runHook preInstall
      mkdir -p $out/lib
      install -Dm755 "$(find target -type f -name libvolt.so -print -quit)" $out/lib/libvolt.so
      runHook postInstall
    '';
  };

  pythonEnv = python3Packages.python.withPackages (ps: [
    ps.pyside6
  ]);

in
stdenv.mkDerivation {
  pname = "volt-gui";
  inherit version src;

  nativeBuildInputs = [
    makeWrapper
    qt6.wrapQtAppsHook
  ];

  buildInputs = [
    qt6.qtbase
    qt6.qtwayland
  ];

  dontWrapQtApps = true;
  dontConfigure = true;
  dontBuild = true;

  installPhase = ''
    runHook preInstall

    # Install 64-bit and 32-bit layers into strict architecture-specific
    # layouts.
    # The Vulkan loader scans architecture-specific subdirectories natively.
    install -Dm755 ${volt64}/lib/libvolt.so $out/lib/volt/x86_64-linux-gnu/libvolt.so
    install -Dm755 ${volt32}/lib/libvolt.so $out/lib/volt/i386-linux-gnu/libvolt.so

    # Install manifest
    install -Dm644 VkLayer_volt.json $out/share/vulkan/implicit_layer.d/VkLayer_volt.json

    # Install Python GUI files
    mkdir -p $out/share/volt-gui
    cp -r src/volt-gui/. $out/share/volt-gui/

    # Install icon and desktop file
    install -Dm644 images/1.png $out/share/icons/hicolor/256x256/apps/volt-gui.png

    mkdir -p $out/share/applications
    cat > $out/share/applications/volt-gui.desktop <<EOF
    [Desktop Entry]
    Type=Application
    Version=1.0
    Name=volt-gui
    Comment=Vulkan game control panel
    Exec=volt-gui
    Icon=volt-gui
    Terminal=false
    Categories=Utility;
    Keywords=vulkan;vsync;gpu;gaming;
    StartupNotify=true
    StartupWMClass=volt-gui
    EOF

    # volt wrapper: Both library architecture folders must be on
    # LD_LIBRARY_PATH so launched games can find the respective libvolt.so
    # layer dynamically. VK_ADD_IMPLICIT_LAYER_PATH registers our layer with
    # the game process loader.
    makeWrapper ${volt64}/bin/volt $out/bin/volt \
      --prefix LD_LIBRARY_PATH : "$out/lib/volt/x86_64-linux-gnu:$out/lib/volt/i386-linux-gnu" \
      --prefix VK_ADD_IMPLICIT_LAYER_PATH : "$out/share/vulkan/implicit_layer.d"

    # volt-probe wrapper: The Rust 'ash' crate loads libvulkan.so dynamically
    # using dlopen at runtime. It requires vulkan-loader on LD_LIBRARY_PATH
    # to succeed.
    makeWrapper ${volt64}/bin/volt-probe $out/bin/volt-probe \
      --prefix LD_LIBRARY_PATH : "${lib.makeLibraryPath [ vulkan-loader ]}"

    # volt-gui wrapper: Wrapped with qtWrapperArgs (from wrapQtAppsHook) to map
    # the Qt platform plugins, making Wayland and X11 graphics contexts
    # discoverable by PySide6.
    makeWrapper ${pythonEnv}/bin/python $out/bin/volt-gui \
      ''${qtWrapperArgs[@]} \
      --prefix PATH : "$out/bin" \
      --add-flags "$out/share/volt-gui/volt-gui.py"

    runHook postInstall
  '';

  passthru = {
    layer32 = volt32;
  };

  meta = with lib; {
    description = "Control panel for Vulkan games on Linux";
    homepage = "https://github.com/pythonlover02/volt-gui";
    license = licenses.gpl3Only;
    platforms = [ "x86_64-linux" ];
    mainProgram = "volt-gui";
  };
}
