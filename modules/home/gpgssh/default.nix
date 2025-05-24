{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.gpgssh;
in
with lib;
{
  options = {
    forge.home.gpgssh = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gpgssh configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      ".gnupg/gpg.conf" = {
        source = ./gnupg-gpg.conf;
      };
      ".gnupg/gpg-agent.conf" = {
        source = pkgs.replaceVars ./gnupg-gpg-agent.conf {
          pinentry = "${pkgs.pinentry-qt}";
        };
      };
      ".ssh/_config" = {
        text = "dummy";
        onChange = ''
          cp ${./ssh-config} ~/.ssh/config
          chmod 600 ~/.ssh/config
        '';
      };
      ".ssh/_id_ed25519" = {
        text = "dummy";
        onChange = ''
          cp ${./ssh-id-ed25519} ~/.ssh/id_ed25519
          chmod 644 ~/.ssh/id_ed25519
        '';
      };
    };
  };
}
