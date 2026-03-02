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
        k8sHomelab = "/etc/ssl/certs/k8s-ca-homelab.crt";
        k8sHomelabContent = builtins.shell "if [ -f ${k8sHomelab} ]; then cat ${k8sHomelab}; fi";
      in
      (optional (homelabContent != "") homelabContent)
      ++ (optional (k8sHomelabContent != "") k8sHomelabContent);
  };
}
