final: prev: {
  xrizer = prev.xrizer.overrideAttrs (
    finalAttrs: prevAttrs: {
      version = "0.5-2026-09-03";
      src = prev.fetchFromGitHub {
        owner = "Supreeeme";
        repo = "xrizer";
        rev = "0989a7fac2d1efb7ea82f5fe1a8ed30c3eeb9596";
        hash = "sha256-Rb1pssAq6Zx6VmQVQtGcThkA6zCwi5X7G7aHmdsDrJo=";
      };
      cargoDeps = prev.rustPlatform.fetchCargoVendor {
        inherit (finalAttrs) src;
        hash = "sha256-JKQUrHGqnU5453iVKXnO51nX2NqcBYzsfvuu92WhLDE=";
      };
      postPatch = ''
        substituteInPlace src/graphics_backends/gl.rs \
          --replace-fail 'libGLX.so.0' '${prev.lib.getLib prev.libGL}/lib/libGLX.so.0'
      '';
    }
  );
}
