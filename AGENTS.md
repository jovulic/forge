# Project: Forge

This repository, "Forge," is a Nix-based project for managing system and home configurations. It uses Nix Flakes to define dependencies and configurations for different hosts.

## Project Overview

The project is structured to manage configurations for multiple machines, referred to as "hosts." Each host has a system-level configuration (NixOS) and a user-level configuration (home-manager).

- **Nix Flakes:** The project is built around Nix Flakes, with the main entry point being `flake.nix`. This file defines the project's dependencies, such as `nixpkgs` and `home-manager`, and exposes the final configurations.
- **Hosts:** Configurations for individual machines are located in the `hosts` directory. Each host has a `system.nix` for system-wide settings and a `home.nix` for user-specific settings.
- **Modules:** Reusable configuration components are organized into modules under the `modules` directory. These modules are categorized into `home` and `system` modules.
- **Custom Tools:** The project includes custom tools, `ctl` and `forge`, to simplify common tasks.

## Building and Running

The primary tools for interacting with this project are `ctl` and `forge`.

### `ctl` commands

The `ctl` tool provides the following commands for managing the configurations:

- `ctl apply [system|home]`: Apply the system or home configuration.
- `ctl update`: Update the flake's dependencies.
- `ctl clean`: Perform garbage collection to clean up unused Nix store paths.

### `forge` commands

The `forge` tool is a wrapper that provides additional functionality:

- `forge run <ctl command>`: Execute a `ctl` command.
- `forge inspect`: Inspect the NixOS configuration.
- `forge index`: Build the Nix index for faster searches.
- `forge packages`: Search for Nix packages.
- `forge options [home]`: Search for NixOS or home-manager options.

## Development Conventions

- **Modularity:** Configurations are broken down into smaller, reusable modules. This makes it easier to share settings between hosts and to manage the complexity of the configurations.
- **Host-specific Configurations:** Each host has its own directory under `hosts` containing its `system.nix` and `home.nix` files. This allows for easy customization of individual machines.
- **Custom Packages:** Custom packages are defined in the `pkgs` directory.
