{ nix-shell-builtin }:
_: prev: {
  # test:
  # $ nix shell .#nixosConfigurations.test-overlay.pkgs.nix --command bash
  # $ nix config show | grep plugin
  nix = prev.nix.overrideAttrs (old: {
    nativeBuildInputs = (old.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];
    installPhase = (old.installPhase or "") + ''
      for bin in $out/bin/*; do
        # Wrap executables, including symlinks to them.
        if [ -x "$bin" ]; then
          wrapProgram "$bin" \
            --add-flags "--option plugin-files ${nix-shell-builtin}/lib/nix/plugins/libnix-shell-builtin.so" \
            --add-flags "--option enable-shell true"
        fi
      done
    '';
  });
}
