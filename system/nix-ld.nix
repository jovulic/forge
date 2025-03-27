{
  config,
  pkgs,
  lib,
  ...
}:
let
  cfg = config.forge.system.nix-ld;
in
with lib;
{
  options = {
    forge.system.nix-ld = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable nix-ld configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.nix-ld
    ];
    programs.nix-ld = {
      enable = true;
    };
    # https://wiki.nixos.org/wiki/Python#Using_nix-ld
    # {
    #   programs.nix-ld = {
    #     enable = true;
    #     libraries = with pkgs; [
    #       zlib zstd stdenv.cc.cc curl openssl attr libssh bzip2 libxml2 acl libsodium util-linux xz systemd
    #     ];
    #   };
    #   # https://github.com/nix-community/nix-ld?tab=readme-ov-file#my-pythonnodejsrubyinterpreter-libraries-do-not-find-the-libraries-configured-by-nix-ld
    #   environment.systemPackages = [
    #     (pkgs.writeShellScriptBin "python" ''
    #       export LD_LIBRARY_PATH=$NIX_LD_LIBRARY_PATH
    #       exec ${pkgs.python3}/bin/python "$@"
    #     '')
    #   ];
    # }
  };
}
