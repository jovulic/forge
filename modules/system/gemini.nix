{
  config,
  lib,
  unstablepkgs,
  ...
}:
let
  cfg = config.forge.system.gemini;
in
with lib;
{
  options = {
    forge.system.gemini = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gemini configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      (unstablepkgs.gemini-cli.overrideAttrs (
        final:
        let
          version = "0.27.3";
          src = final.src.override {
            tag = "v${version}";
            hash = "sha256-JUSl5yRJ2YtTCMfPv7oziaZG4yNnsucKlvtjfuzZO+I=";
          };
          npmDeps = unstablepkgs.fetchNpmDeps {
            inherit src;
            hash = "sha256-euy7QwuoJI+07KMUMcRAmmH/zyYgF9wFiLSF4OwQivo=";
          };
        in
        {
          inherit version;
          inherit src;
          inherit npmDeps;

          disallowedReferences = [ ];

          postPatch = with unstablepkgs; ''
            # Remove node-pty from manifests.
            ${jq}/bin/jq 'del(.optionalDependencies."node-pty")' package.json > package.json.tmp && mv package.json.tmp package.json
            ${jq}/bin/jq 'del(.optionalDependencies."node-pty")' packages/core/package.json > packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

            # Fix ripgrep path.
            substituteInPlace packages/core/src/tools/ripGrep.ts \
              --replace-fail "await ensureRgPath();" "'${lib.getExe ripgrep}';"
          '';
        }
      ))
    ];
  };
}
