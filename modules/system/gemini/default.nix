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
          version = "0.40.0";
          src = final.src.override {
            tag = "v${version}";
            hash = "sha256-d9CtwQQmblQs9BqdWPY9z9Q1fC41830Xqa1L2SFgEpI=";
          };
          npmDeps = unstablepkgs.fetchNpmDeps {
            inherit src;
            hash = "sha256-mLldQUB8mFoeyXF90y1pPzM87LETCmJAAP/JlnTzgFc=";
          };
        in
        {
          inherit version;
          inherit src;
          inherit npmDeps;

          disallowedReferences = [ ];

          preConfigure = ''
            # Bypass git errors by directly injecting telemetry files.
            for dir in packages/core/src/generated packages/cli/src/generated; do
              mkdir -p "$dir"
              cat << 'EOF' > "$dir/git-commit.ts"
            export const GIT_COMMIT_INFO = "${version}";
            export const CLI_VERSION = "${version}";
            EOF
            done

            # Empty the generator script to prevent git errors or overwriting
            # our injected files.
            echo "" > scripts/generate-git-commit-info.js
          '';

          # We override postPatch completely to avoid failing base patches from
          # older versions.
          postPatch = with unstablepkgs; ''
            # Remove node-pty from manifests.
            ${jq}/bin/jq 'del(.optionalDependencies."node-pty")' package.json > package.json.tmp && mv package.json.tmp package.json
            ${jq}/bin/jq 'del(.optionalDependencies."node-pty")' packages/core/package.json > packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

            # Fix ripgrep path explicitly.
            # We replace both ensureRgPath and getRipgrepPath call sites to be safe.
            substituteInPlace packages/core/src/tools/ripGrep.ts \
              --replace-fail "await ensureRgPath()" "'${lib.getExe ripgrep}'" \
              --replace-fail "await getRipgrepPath()" "'${lib.getExe ripgrep}'"

            # Disable auto-update.
            # Patch defaults in settings schema.
            sed -i '/enableAutoUpdate: {/,/}/ s/default: true/default: false/' packages/cli/src/config/settingsSchema.ts
            sed -i '/enableAutoUpdateNotification: {/,/}/ s/default: true/default: false/' packages/cli/src/config/settingsSchema.ts
            # Patch the notification logic to always skip.
            substituteInPlace packages/cli/src/utils/handleAutoUpdate.ts \
              --replace-fail "!settings.merged.general.enableAutoUpdateNotification" "true"
            substituteInPlace packages/cli/src/ui/utils/updateCheck.ts \
              --replace-fail "!settings.merged.general.enableAutoUpdateNotification" "true"
          '';

          preBuild = ''
            # Explicitly run the bundle command which populates the 'bundle/'
            # directory.
            npm run bundle
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/{bin,share/gemini-cli}

            # Prune devDependencies to keep the closure small.
            npm prune --omit=dev

            # Remove problematic files for Nix closures.
            find node_modules -name "*.py" -delete
            rm -rf node_modules/keytar/build

            # Remove workspace symlinks that point to the build tree.
            rm -rf node_modules/@google/gemini-cli*
            rm -rf node_modules/gemini-cli-vscode-ide-companion
            # Remove the .bin directory as it contains symlinks pointing to the
            # deleted workspace packages.
            rm -rf node_modules/.bin

            # Copy standard node_modules.
            cp -r node_modules $out/share/gemini-cli/

            # Copy the bundle output. 
            # Use -aL to dereference symlinks (docs, skills, etc.) into real
            # files.
            cp -aL bundle $out/share/gemini-cli/bundle

            # Link the binary to the bundled executable.
            ln -s $out/share/gemini-cli/bundle/gemini.js $out/bin/gemini
            chmod +x "$out/bin/gemini"

            # Final cleanup of build-time metadata.
            find $out/share/gemini-cli -name "package-lock.json" -delete
            find $out/share/gemini-cli -name ".package-lock.json" -delete
            find $out/share/gemini-cli -name "config.gypi" -delete

            runHook postInstall
          '';
        }
      ))
    ];
  };
}
