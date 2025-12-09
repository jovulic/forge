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
      unstablepkgs.gemini-cli
    ];
  };
}
