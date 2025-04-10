{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.haskell;
in
with lib;
{
  options = {
    forge.system.haskell = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable haskell configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      pkgs.ghc
      pkgs.ghcid
      pkgs.cabal-install # $ cabal update
    ];
  };
}
