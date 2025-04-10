{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.aws;
in
with lib;
{
  options = {
    forge.system.aws = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable aws configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      awscli
      aws-mfa
    ];
  };
}
