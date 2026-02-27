{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.certificates;
in
with lib;
{
  options = {
    forge.system.certificates = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable certificates configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    security.pki.certificates =
      let
        homelab = "/etc/ssl/certs/ca-homelab.crt";
        homelabContent = builtins.shell "if [ -f ${homelab} ]; then cat ${homelab}; fi";
      in
      optional (homelabContent != "") homelabContent;
  };
}
