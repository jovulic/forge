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

    home.file.".kube/config-homelab.yaml" = {
      text = ''
        apiVersion: v1
        clusters:
        - cluster:
            certificate-authority-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUI0VENDQVlhZ0F3SUJBZ0lVRmlOZnJ5d3JBcnFJbytVVnZrS2FDZTB3bVB3d0NnWUlLb1pJemowRUF3SXcKUGpFUU1BNEdBMVVFQ2hNSFNHOXRaV3hoWWpFUU1BNEdBMVVFQ3hNSFVtOXZkQ0JEUVRFWU1CWUdBMVVFQXhNUApTRzl0Wld4aFlpQlNiMjkwSUVOQk1CNFhEVEkyTURNd01UQXhORFV3TUZvWERUTXhNREl5T0RBeE5EVXdNRm93Ck9qRVFNQTRHQTFVRUNoTUhTRzl0Wld4aFlqRU9NQXdHQTFVRUN4TUZTRzl6ZEhNeEZqQVVCZ05WQkFNVERVdDEKWW1WeWJtVjBaWE1nUTBFd1dUQVRCZ2NxaGtqT1BRSUJCZ2dxaGtqT1BRTUJCd05DQUFSeWYzaDhQKzR1cUpiOAptUEwwVkl6UU9TckZnZGlpc2x4cE9rWkc0TXlZNGQvbWNZT1FscTFvdlJNL2x1QXVKZm1xR2M4VmY2bjRoK1FDCkdkb0Mrckw3bzJZd1pEQU9CZ05WSFE4QkFmOEVCQU1DQWFZd0VnWURWUjBUQVFIL0JBZ3dCZ0VCL3dJQkFUQWQKQmdOVkhRNEVGZ1FVdXNHYnY5eTZPYVZySGFDR3pwUUUwbFFRd2NNd0h3WURWUjBqQkJnd0ZvQVVJcDVSSDkwLwpWRHA4MEZscEFtYnE2THlWODJNd0NnWUlLb1pJemowRUF3SURTUUF3UmdJaEFLM1k1UlI2ZjlvWHBBejNtWk9RCmF2RHJyQzdwQkVQQUkrYm0rUXdXRktFWUFpRUFzcUppYWk4VGRNeGI2b0dzQlZheG5iTEpKcXQ0WEVhektIWkMKR3l4ejRQcz0KLS0tLS1FTkQgQ0VSVElGSUNBVEUtLS0tLQo=
            server: https://frost.lan:6443
          name: homelab
        contexts:
        - context:
            cluster: homelab
            user: me
          name: me@homelab
        - context:
            cluster: homelab
            user: me
          name: me-oidc@homelab
        current-context: ""
        kind: Config
        preferences: {}
        users:
        - name: me
          user:
            client-certificate-data: LS0tLS1CRUdJTiBDRVJUSUZJQ0FURS0tLS0tCk1JSUNzVENDQWxpZ0F3SUJBZ0lVR0VDY2xKbDNsRmMyVVpQdTE1TVc3b1ZRSDlZd0NnWUlLb1pJemowRUF3SXcKT2pFUU1BNEdBMVVFQ2hNSFNHOXRaV3hoWWpFT01Bd0dBMVVFQ3hNRlNHOXpkSE14RmpBVUJnTlZCQU1URFV0MQpZbVZ5Ym1WMFpYTWdRMEV3SGhjTk1qWXdNekF4TURRd09UQXdXaGNOTWpZd016TXhNRFF3T1RBd1dqQXhNUmN3CkZRWURWUVFLRXc1emVYTjBaVzA2YldGemRHVnljekVXTUJRR0ExVUVBeE1OWTJ4MWMzUmxjaTFoWkcxcGJqQ0MKQVNJd0RRWUpLb1pJaHZjTkFRRUJCUUFEZ2dFUEFEQ0NBUW9DZ2dFQkFOaWhBNzdhemsxa1MxYlduSnA2K2pUWgpkQjhCNFAyZTU0VndvRWg1Q1VNU3ovQ0wxYjN6OWUrOGQwUUo1WUF1eitvN2QvMGhYWWtlUlhGVGJTK25TTzZwClV0TlFiUCtQR1hncDZ5T2lpaytOM0dudnZkTFQ5Wi9EY1ZZWkF1S3Rqbk5JbkNuWC9LZlN3TitReWZVdm9mK2EKRWQwNFJTZG12N2tmbk9hWHBidzNTYXhsMGxraTkwYnRtSlhoRjAranJIeWVNeW1YYUVLQS95bmxuczFKWVUzdwprRmU5ZHZtUkxYK01KS0wvU3llUHhnV1ViTFExSyt4Z3haRkRieDhtL24vT1FaK1NEY0dWN1VhMVU3bS9KdStMClZXNnZhbE9UMXlFSlFzVGJ5QmNYUFNZY1ltYm0vb0xmanRLQmdGcGtESnJlb1JXRlZ4UEx3ZW5hRkhsT2ZBTUMKQXdFQUFhTjZNSGd3RGdZRFZSMFBBUUgvQkFRREFnZUFNQXdHQTFVZEV3RUIvd1FDTUFBd0hRWURWUjBPQkJZRQpGQ25lY3U0bVV0Y3Q1V3FJQzlkOVoyODdCd1RQTUI4R0ExVWRJd1FZTUJhQUZMckJtNy9jdWptbGF4MmdoczZVCkJOSlVFTUhETUJnR0ExVWRFUVFSTUErQ0RXTnNkWE4wWlhJdFlXUnRhVzR3Q2dZSUtvWkl6ajBFQXdJRFJ3QXcKUkFJZ1FxeUpabS9qdU9wRTZPd21NOWplekQ4Qm05Vkdhb2JKREtaYThGK2RyRDhDSUhqWHkzdEFoUC84dURWWQpBaHM4TEh5TDRoQWEzdk9aNVF0VUpPVUlZZzdvCi0tLS0tRU5EIENFUlRJRklDQVRFLS0tLS0K
            client-key-data: ${builtins.shell "gopass show -o --nosync homelab/kubernetes/client-cert-key-data"}
        - name: me-oidc
          user:
            exec:
              apiVersion: client.authentication.k8s.io/v1beta1
              command: kubectl
              args:
              - oidc-login
              - get-token
              - --oidc-issuer-url=https://identity.lab/oauth2/openid/kubernetes
              - --oidc-client-id=kubernetes
              - --oidc-client-secret=${builtins.shell "gopass show -o --nosync homelab/identity/kubernetes"}
              - --oidc-extra-scope=email
      '';
    };

    home.sessionVariables = {
      KUBECONFIG = "$HOME/.kube/config";
      KUBETAIL_SHOW_COLOR_INDEX = "true";
      KUBETAIL_SKIP_COLORS = "16,17,18,19,20,21";
    };

    home.sessionPath = [ "$HOME/.krew/bin" ];
  };
}
