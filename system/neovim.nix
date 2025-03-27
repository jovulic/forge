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
      pkgs.nodePackages.bash-language-server # pack(bash)
      pkgs.shfmt # pack(bash)
      pkgs.shellcheck # pack(bash)
      pkgs.dockerfile-language-server-nodejs # pack(dockerfile)
      pkgs.hadolint # pack(dockerfile)
      pkgs.gopls # pack(go)
      pkgs.gofumpt # pack(go)
      pkgs.gotools # pack(go) "goimports"
      pkgs.gomodifytags # pack(go)
      pkgs.iferr # pack(go)
      pkgs.impl # pack(go)
      pkgs.delve
      pkgs.gotests
      pkgs.nodePackages.vscode-json-languageserver # pack(json)
      (pkgs.writeShellScriptBin "vscode-json-language-server" ''
        vscode-json-languageserver $@
      '') # because of the jsonls command configuration
      pkgs.lua-language-server # pack(lua)
      pkgs.stylua # pack(lua)
      pkgs.selene # pack(lua)
      pkgs.marksman # pack(markdown)
      pkgs.alejandra # pack(nix)
      pkgs.deadnix # pack(nix)
      pkgs.statix # pack(nix)
      pkgs.buf # pack(proto)
      pkgs.pyright # pack(python)
      pkgs.black # pack(python)
      pkgs.isort # pack(python)
      pkgs.python311Packages.debugpy # pack(python)
      pkgs.sqls # pack(sql)
      pkgs.taplo # pack(toml)
      (pkgs.symlinkJoin {
        name = "typescript-language-server";
        paths = [ pkgs.nodePackages.typescript-language-server ];
        buildInputs = [ pkgs.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/typescript-language-server \
            # NB(jv): No longer require/working (error of "unknown option").
            # --add-flags --tsserver-path=${pkgs.nodePackages.typescript}/lib/node_modules/typescript/lib/
        '';
      }) # pack(typescript)
      pkgs.nodePackages.eslint # pack(typescript) or "vscode-extensions.dbaeumer.vscode-eslint"?
      pkgs.prettierd # pack(typescript,yaml,markdown)
      pkgs.yaml-language-server # pack(yaml)
      pkgs.nixd # pack(nix)
      pkgs.nixfmt-rfc-style # custom~pack(nix)
      pkgs.nodePackages.vls # pack(vue)
      # markdown-preview (cd ~/.local/share/nvim/lazy/markdown-preview.nvim; npm install)
      pkgs.neovide
      pkgs.clang-tools # pack(cpp)
    ];

    environment.variables = {
      RUST_SRC_PATH = "${pkgs.rustPlatform.rustLibSrc}"; # was necessary to get rust-analyzer to work
    };
  };
}
