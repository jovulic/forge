{
  config,
  lib,
  unstablepkgs,
  ...
}:
let
  cfg = config.forge.system.antigravity;
in
with lib;
{
  options = {
    forge.system.antigravity = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable antigravity configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      unstablepkgs.antigravity-cli
      unstablepkgs.antigravity-hub
      unstablepkgs.antigravity-acp
    ];
  };
}
