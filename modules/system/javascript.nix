{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.javascript;
in
with lib;
{
  options = {
    forge.system.javascript = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable javascript configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.nodejs
      pkgs.nodePackages.typescript
      pkgs.nodePackages.eslint
      pkgs.nodePackages.pnpm
      pkgs.deno
    ];
  };
}
