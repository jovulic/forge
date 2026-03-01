{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.kubernetes;
in
with lib;
{
  options = {
    forge.home.kubernetes = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kubernetes configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file.".kube/kubie.yaml" = {
      text = ''
        configs:
          include:
            - ~/.kube/config
            - ~/.kube/config-*
        prompt:
          disable: true
        behavior:
          validate_namespaces: false
      '';
    };

    # home.file.".kube/config-home.yaml" = {
    #   text = ''
    #     apiVersion: v1
    #     clusters:
    #     - cluster:
    #         certificate-authority-data: ${builtins.shell "gopass show -o --nosync home/k8s/-/ca-certificate"}
    #         server: https://frost.lan:6443
    #       name: home
    #     contexts:
    #     - context:
    #         cluster: home
    #         user: me
    #       name: me@home
    #     - context:
    #         cluster: home
    #         user: me
    #       name: me-oidc@home
    #     current-context: ""
    #     kind: Config
    #     preferences: {}
    #     users:
    #     - name: me
    #       user:
    #         client-certificate-data: ${builtins.shell "gopass show -o --nosync home/k8s/-/me-certificate"}
    #         client-key-data: ${builtins.shell "gopass show -o --nosync home/k8s/-/me-certificate-key"}
    #     - name: me-oidc
    #       user:
    #         exec:
    #           apiVersion: client.authentication.k8s.io/v1beta1
    #           command: kubectl
    #           args:
    #           - oidc-login
    #           - get-token
    #           - --oidc-issuer-url=https://sso.bootstrap.home/dex
    #           - --oidc-client-id=kubernetes
    #           - --oidc-client-secret=${builtins.shell "gopass show -o --nosync home/bm/optiplexm/portunus/client/kubernetes"}
    #           - --oidc-extra-scope=email
    #   '';
    # };

    home.sessionVariables = {
      KUBECONFIG = "$HOME/.kube/config";
      KUBETAIL_SHOW_COLOR_INDEX = "true";
      KUBETAIL_SKIP_COLORS = "16,17,18,19,20,21";
    };

    home.sessionPath = [ "$HOME/.krew/bin" ];
  };
}
