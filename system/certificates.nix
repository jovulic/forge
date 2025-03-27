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
    security.pki.certificates = [
      "${builtins.shell "gopass show -o home/bm/optiplexm/ca-certificate | base64 -d"}"
      "${builtins.shell "gopass show -o home/k8s/-/ca-certificate | base64 -d"}"
      "${builtins.shell "gopass show -o home/k8s/-/cluster-ca-certificate | base64 -d"}"
    ];
  };
}
