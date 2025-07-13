{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.neovim;
in
with lib;
{
  options = {
    forge.system.neovim = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable neovim configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.nodejs
      pkgs.python3
      (pkgs.wrapNeovim pkgs.neovim-unwrapped {
        withRuby = true;
        withPython3 = true;
        withNodeJs = true;
      })
      pkgs.tree-sitter
      pkgs.ripgrep # astrovim
      pkgs.lazygit # astrovim
      pkgs.gdu # astrovim
      pkgs.bottom # astrovim
      pkgs.clang # astrovim

      # astrovim pack=lua
      pkgs.lua-language-server
      pkgs.selene
      pkgs.stylua

      # astrovim pack=bash
      pkgs.shfmt
      pkgs.shellcheck
      pkgs.bash-language-server

      # astrovim pack=docker
      # docker_compose_language_service
      # dockerls
      pkgs.hadolint
      pkgs.prettierd

      # astrovim pack=fish

      # astrovim pack=json
      # jsonls

      # astrovim pack=yaml
      # yamlls
      pkgs.prettierd

      # astrovim pack=toml
      pkgs.taplo

      # astrovim pack=markdown
      pkgs.marksman
      pkgs.prettierd

      # astrovim pack=sql
      pkgs.sqls
      pkgs.go # required by sqls
      pkgs.sqlfluff

      # astrovim pack=proto
      pkgs.buf
      # buf_ls

      # astrovim pack=nix
      pkgs.nixd
      pkgs.nixfmt-rfc-style # required by nixd
      pkgs.statix
      pkgs.deadnix

      # astrovim pack=go
      pkgs.gopls
      pkgs.gotools # goimports
      pkgs.gomodifytags
      pkgs.gotests
      pkgs.iferr
      pkgs.impl

      # astrovim pack=golangci-lint
      pkgs.golangci-lint
      pkgs.golangci-lint-langserver
      pkgs.exhaustive
      pkgs.go-tools # staticcheck + others

      # astrovim pack=typescript
      pkgs.vtsls
      pkgs.eslint
      pkgs.prettierd

      # astrovim pack=vue
      pkgs.vue-language-server

      # astrovim pack=python
      pkgs.basedpyright
      pkgs.black
      pkgs.isort

      # astrovim pack=cpp
      pkgs.clang-tools # clangd, clang-format

      # markdown-preview (cd ~/.local/share/nvim/lazy/markdown-preview.nvim; npm install)

      pkgs.neovide
    ];

    environment.variables = {
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}"; # was necessary to get rust-analyzer to work
    };
  };
}
