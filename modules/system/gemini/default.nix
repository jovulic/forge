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
      (unstablepkgs.buildNpmPackage rec {
        pname = "gemini-cli";
        version = "0.55.1";

        src = unstablepkgs.fetchFromGitHub {
          owner = "google-gemini";
          repo = "gemini-cli";
          tag = "v${version}";
          hash = "sha256-RKgvIoUKgiMOLLd/rTrJ2n3Ob6zSp0lQUULJ+W1lTHg=";
        };

        npmDepsHash = "sha256-xw+QVMArygYHmcKAI/vodHItzQmfyXIn9HaCqMlJ0KI=";

        postPatch = ''
          # Remove node-pty from optionalDependencies in package.json and packages/core/package.json
          ${unstablepkgs.jq}/bin/jq 'del(.optionalDependencies."node-pty")' package.json > package.json.tmp && mv package.json.tmp package.json
          ${unstablepkgs.jq}/bin/jq 'del(.optionalDependencies."node-pty")' packages/core/package.json > packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

          # Remove node-pty from package-lock.json to maintain consistency
          ${unstablepkgs.jq}/bin/jq 'del(.packages."".optionalDependencies."node-pty") | del(.packages."packages/core".optionalDependencies."node-pty") | del(.packages."node_modules/node-pty")' package-lock.json > package-lock.json.tmp && mv package-lock.json.tmp package-lock.json

          # Prepend ^ to all exact dependency versions in workspace manifests to prevent offline semver resolution errors
          ${unstablepkgs.jq}/bin/jq '.dependencies |= map_values(if type == "string" and (startswith("file:") or startswith("npm:") or startswith("^")) then . else "^" + . end)' packages/cli/package.json > packages/cli/package.json.tmp && mv packages/cli/package.json.tmp packages/cli/package.json
          ${unstablepkgs.jq}/bin/jq '.dependencies |= map_values(if type == "string" and (startswith("file:") or startswith("npm:") or startswith("^")) then . else "^" + . end)' packages/a2a-server/package.json > packages/a2a-server/package.json.tmp && mv packages/a2a-server/package.json.tmp packages/a2a-server/package.json

          # Prefer the Nix ripgrep binary by prepending it to candidate paths.
          substituteInPlace packages/core/src/tools/ripGrep.ts \
            --replace-fail "const candidatePaths = [" "const candidatePaths = [\"${lib.getExe unstablepkgs.ripgrep}\", "

          # Trust the Nix store path by adding it to standard system prefixes.
          substituteInPlace packages/core/src/utils/paths.ts \
            --replace-fail "const trustedPrefixes = [" "const trustedPrefixes = [\"/nix/store\", "

          # Disable auto-update by changing default values in settings schema.
          sed -i '/enableAutoUpdate:/,/default: true/ s/default: true/default: false/' packages/cli/src/config/settingsSchema.ts
          sed -i '/enableAutoUpdateNotification:/,/default: true/ s/default: true/default: false/' packages/cli/src/config/settingsSchema.ts

          # Also make sure the values are disabled in runtime code by changing
          # condition checks to false.
          substituteInPlace packages/cli/src/utils/handleAutoUpdate.ts \
            --replace-fail "if (!settings.merged.general.enableAutoUpdateNotification) {" "if (false) {" \
            --replace-fail "settings.merged.general.enableAutoUpdate," "false," \
            --replace-fail "!settings.merged.general.enableAutoUpdate" "!false"
        '';

        nodejs = unstablepkgs.nodejs_22;
        npmDepsFetcherVersion = 2;
        npmFlags = [ "--legacy-peer-deps" ];

        nativeBuildInputs = with unstablepkgs; [
          jq
          pkg-config
          makeWrapper
        ];

        buildInputs = with unstablepkgs; [
          ripgrep
          libsecret
        ];

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

        npmBuildScript = "bundle";

        # Prevent npmDeps and python from getting into the closure.
        disallowedReferences = [
          nodejs.python
        ];

        installPhase = ''
          runHook preInstall

          mkdir -p $out/{bin,share/gemini-cli}

          # Copy bundle output.
          cp -r bundle/* $out/share/gemini-cli/

          # Keep standard node_modules and prune devDependencies.
          cp -r node_modules $out/share/gemini-cli/
          npm prune --omit=dev --prefix $out/share/gemini-cli

          # Clean up unnecessary files and broken symlinks to keep closure
          # small.
          find $out/share/gemini-cli -name "*.py" -delete
          find $out/share/gemini-cli -name "package-lock.json" -delete
          find $out/share/gemini-cli -name ".package-lock.json" -delete
          find $out/share/gemini-cli -name "config.gypi" -delete
          find $out/share/gemini-cli -type l -delete

          # Wrap binary with Node.js.
          makeWrapper "${lib.getExe unstablepkgs.nodejs_22}" "$out/bin/gemini" \
            --add-flags "--no-warnings=DEP0040" \
            --add-flags "$out/share/gemini-cli/gemini.js"

          runHook postInstall
        '';

        meta = {
          description = "AI agent that brings the power of Gemini directly into your terminal";
          homepage = "https://github.com/google-gemini/gemini-cli";
          license = lib.licenses.asl20;
          platforms = lib.platforms.all;
          mainProgram = "gemini";
        };
      })
    ];
  };
}
