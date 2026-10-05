# Rust

## Cross-Compiling for macOS

When cross-compiling Rust projects for macOS targets (such as `aarch64-apple-darwin` or `x86_64-apple-darwin`), Apple's macOS SDK is required for linking against macOS system libraries and frameworks.

Because the SDK cannot be redistributed directly via Nixpkgs due to licensing, it must be acquired manually and placed on the host machine.

### 1. Create Archive on macOS

Run the following command on a macOS machine with Xcode Command Line Tools installed to package the SDK:

```bash
COPYFILE_DISABLE=1 tar -czf ~/MacOSX.sdk.tar.gz -C "/Library/Developer/CommandLineTools/SDKs/MacOSX.sdk" .
```

### 2. Extract on Host

Transfer `MacOSX.sdk.tar.gz` to the host machine and extract it to `~/.local/share/sdks/MacOSX.sdk`:

```bash
# Create the target SDK directory.
mkdir -p ~/.local/share/sdks/MacOSX.sdk

# Extract into that directory.
tar -xzf MacOSX.sdk.tar.gz -C ~/.local/share/sdks/MacOSX.sdk

# Clean up the archive (or move to a backup location).
rm MacOSX.sdk.tar.gz
```

Full path on `licious`:

```
/home/me/.local/share/sdks/MacOSX.sdk
```

### 3. Usage

When compiling, point your build environment or tooling (such as `cargo`, `clang`, `cargo-zigbuild`, or `osxcross`) to the SDK via the `SDKROOT` environment variable:

```bash
export SDKROOT="$HOME/.local/share/sdks/MacOSX.sdk"
```
