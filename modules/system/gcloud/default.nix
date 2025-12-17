{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.gcloud;
in
with lib;
{
  options = {
    forge.system.gcloud = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gcloud configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      (pkgs.google-cloud-sdk.withExtraComponents [
        pkgs.google-cloud-sdk.components.log-streaming
      ])
      pkgs.google-cloud-sql-proxy
      (pkgs.writeShellScriptBin "gcloud-postgres-proxy-default" ''
        cloud-sql-proxy --auto-iam-authn --port 5432 aio-1-371240:us-central1:default
      '')
      (pkgs.writeShellApplication {
        name = "gcloud-resolve-errors";
        runtimeInputs = [
          pkgs.curl
          pkgs.jq
        ];
        text = builtins.readFile ./gcloud-resolve-errors.sh;
        bashOptions = [
          "errexit"
          "pipefail"
        ];
      })
    ];
  };
}
