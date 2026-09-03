# Project: Forge

This repository, "Forge," is a Nix-based project for managing system and home configurations. It uses Nix Flakes to define dependencies and configurations for different hosts.

## Project Overview

The project is structured to manage configurations for multiple machines, referred to as "hosts." Each host has a system-level configuration (NixOS) and a user-level configuration (home-manager).

- **Nix Flakes:** The project is built around Nix Flakes, with the main entry point being `flake.nix`. This file defines the project's dependencies, such as `nixpkgs` and `home-manager`, and exposes the final configurations.
- **Hosts:** Configurations for individual machines are located in the `hosts` directory:
  - **`licious`**: Main AMD workstation/gaming rig. Features Secure Boot (`lanzaboote`), AMD GPU tuning (`lact` and `amd`), local AI runtime (`lllm` running ROCm-accelerated `llama-cpp`), VR, GameMode, and custom kernel scheduling (`scx_lavd`).
  - **`expert`**: Workstation/laptop configuration containing OpenRazer, GameMode, and Steam configurations.
  - **`test`**: Minimalist testing host (`test-overlay`) with in-memory filesystems. Imports all system modules and resolves all custom inputs. Used as a syntax and option-checking testbed.
- **Modules:** Reusable configuration components are organized into modules under the `modules` directory, categorized into `home` and `system` modules.
- **Custom Tools:** The project includes custom tools, `ctl` and `forge`, to simplify common tasks.

## Building and Running

The primary tools for interacting with this project are `ctl` and `forge`.

### `ctl` commands

The `ctl` tool (built via Bashly) provides the following commands for managing configurations and dependencies:

- `ctl apply [system|home] [licious|expert]`: Apply system-level or home-manager level configurations. Supports `--dry` for dry-activation and `--debug` for verbose outputs.
- `ctl update [input]`: Update flake dependencies or a specific input.
- `ctl clean`: Perform garbage collection and optimise the Nix store.
- `ctl test [PACKAGE]`: Run codebase verification and package testing using the `test-overlay` testbed:
  - `ctl test`: Run dry-run evaluation and dependency checks on the complete list of system modules to verify the entire repository compiles.
  - `ctl test --eval`: Run syntax/options verification quickly without running dry-run builds.
  - `ctl test <package>`: Compile a specific custom package from `pkgs/` (e.g. `jackify`) within the repository channel context.

### `forge` commands

The `forge` tool is a wrapper that provides additional functionality:

- `forge run <ctl command>`: Execute a `ctl` command.
- `forge inspect`: Inspect the NixOS configuration.
- `forge index`: Build the Nix index for faster searches.
- `forge packages`: Search for Nix packages.
- `forge options [home]`: Search for NixOS or home-manager options.

## Development Conventions

- **Modularity:** Configurations are broken down into smaller, reusable modules. This makes it easier to share settings between hosts and to manage the complexity of configurations.
- **Alphabetical Imports:** All new modules must be imported alphabetically inside `modules/system/default.nix` or `modules/home/default.nix` to preserve repository hygiene.
- **Scope and Variable Hygiene:** Ensure all modules explicitly pull their packages and variables from standard arguments (like `pkgs`, e.g., `pkgs.awscli`) instead of relying on implicit/global namespaces.
- **Testing Before Push:** Always run `ctl test` before committing or applying changes. This guarantees that your changes have no syntax errors, missing variables, or option conflicts across any of the imported system modules.
- **Custom Packages:** New custom packages are defined in the `pkgs` directory and automatically made available inside modules via `mypkgs`. Examples include:
  - `jackify`: GUI and CLI application for automated Wabbajack modlist installation.
  - `mcp-hub`: Custom MCP server coordinator.
  - `plover`: Open-source stenography software.
  - `nix-shell-builtin`: Customized shell wrapper.
