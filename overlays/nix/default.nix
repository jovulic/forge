# NOTE: We create an overlay for nix in order to use the DSO compatible
# nix-shell-plugin. Otherwise, when updating nix when not DSO compatible, we
# will run into errors.
{ nix-shell-builtin }:
_: prev: {
  # test:
  # $ nix shell .#nixosConfigurations.test-overlay.pkgs.nix --command bash
  # $ nix config show | grep plugin
  nix = prev.nix.overrideAttrs (final: {
    nativeBuildInputs = (final.nativeBuildInputs or [ ]) ++ [ prev.makeWrapper ];
    installPhase = (final.installPhase or "") + ''
      wrapProgram "$out/bin/nix" \
        --add-flags "--option plugin-files ${nix-shell-builtin}/lib/nix/plugins/libnix-shell-builtin.so" \
        --add-flags "--option enable-shell true"
    '';
  });
}
