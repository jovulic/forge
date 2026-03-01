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
          version = "0.31.0";
          src = final.src.override {
            tag = "v${version}";
            hash = "sha256-huPd4W7Jf4/dZshWElicYpcHhktE83wPs/z5jVYwynM=";
          };
          npmDeps = unstablepkgs.fetchNpmDeps {
            inherit src;
            hash = "sha256-iRlwCSGigRi/ilfXi8rI68vlfkeec3vB5nZWPmTLnK8=";
          };
        in
        {
          inherit version;
          inherit src;
          inherit npmDeps;

          disallowedReferences = [ ];

          preConfigure = ''
            # Bypass git errors by directly injecting the generated telemetry
            # files.
            for dir in packages/core/src/generated packages/cli/src/generated; do
              mkdir -p "$dir"
              cat << 'EOF' > "$dir/git-commit.ts"
            export const GIT_COMMIT_INFO = "${version}";
            export const CLI_VERSION = "${version}";
            EOF
            done

            # Empty the generator script so it doesn't crash on git or
            # overwrite our injected files.
            echo "" > scripts/generate-git-commit-info.js
          '';

          postPatch = with unstablepkgs; ''
            # Remove node-pty from manifests.
            ${jq}/bin/jq 'del(.optionalDependencies."node-pty")' package.json > package.json.tmp && mv package.json.tmp package.json
            ${jq}/bin/jq 'del(.optionalDependencies."node-pty")' packages/core/package.json > packages/core/package.json.tmp && mv packages/core/package.json.tmp packages/core/package.json

            # Fix ripgrep path.
            substituteInPlace packages/core/src/tools/ripGrep.ts \
              --replace-fail "await ensureRgPath();" "'${lib.getExe ripgrep}';"
          '';

          preBuild = ''
            # Enforce explicit build order for workspaces. Core must compile
            # first so SDK and Devtools have their dependencies satisfied.
            npm run build -w @google/gemini-cli-core
            npm run build -w @google/gemini-cli-sdk
            npm run build -w @google/gemini-cli-devtools
          '';

          installPhase = ''
            runHook preInstall
            mkdir -p $out/{bin,share/gemini-cli}

            npm prune --omit=dev

            # Remove python files to prevent python from getting into the closure.
            find node_modules -name "*.py" -delete
            # keytar/build has gyp-mac-tool with a Python shebang that gets patched,
            # creating a python3 reference in the closure.
            rm -rf node_modules/keytar/build

            cp -r node_modules $out/share/gemini-cli/

            # Remove the uncompiled local workspace symlinks from the copied node_modules.
            rm -rf $out/share/gemini-cli/node_modules/@google/gemini-cli
            rm -rf $out/share/gemini-cli/node_modules/@google/gemini-cli-core
            rm -rf $out/share/gemini-cli/node_modules/@google/gemini-cli-a2a-server
            rm -rf $out/share/gemini-cli/node_modules/@google/gemini-cli-devtools
            rm -rf $out/share/gemini-cli/node_modules/@google/gemini-cli-sdk
            rm -rf $out/share/gemini-cli/node_modules/@google/gemini-cli-test-utils
            rm -rf $out/share/gemini-cli/node_modules/gemini-cli-vscode-ide-companion

            # Copy the compiled workspaces into the final output.
            cp -r packages/cli $out/share/gemini-cli/node_modules/@google/gemini-cli
            cp -r packages/core $out/share/gemini-cli/node_modules/@google/gemini-cli-core
            cp -r packages/a2a-server $out/share/gemini-cli/node_modules/@google/gemini-cli-a2a-server
            cp -r packages/devtools $out/share/gemini-cli/node_modules/@google/gemini-cli-devtools
            cp -r packages/sdk $out/share/gemini-cli/node_modules/@google/gemini-cli-sdk

            rm -f $out/share/gemini-cli/node_modules/@google/gemini-cli-core/dist/docs/CONTRIBUTING.md

            ln -s $out/share/gemini-cli/node_modules/@google/gemini-cli/dist/index.js $out/bin/gemini
            chmod +x "$out/bin/gemini"

            # Clean up any remaining references to npmDeps in node_modules metadata.
            find $out/share/gemini-cli/node_modules -name "package-lock.json" -delete
            find $out/share/gemini-cli/node_modules -name ".package-lock.json" -delete
            find $out/share/gemini-cli/node_modules -name "config.gypi" -delete

            runHook postInstall
          '';
        }
      ))
    ];
  };
}
