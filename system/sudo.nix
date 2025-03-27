{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.sudo;
in
with lib;
{
  options = {
    forge.system.sudo = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable sudo configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages =  [
      (pkgs.writeShellScriptBin "sudoe" ''
        sudo -sE $@
      '')
    ];

    # Audit commands with: $ journalctl _COMM=sudo
    security.sudo = {
      extraRules = [
        {
          users = [ "me" ];
          commands = [
            {
              command = "/nix/store/*/bin/nix-env -p /nix/var/nix/profiles/system --set /nix/store/*";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemd-run -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER= --collect --no-ask-password --pipe --quiet --same-dir --service-type=exec --unit=nixos-rebuild-switch-to-configuration --wait true";
              options = [ "NOPASSWD" ];
            }
            {
              command = "/run/current-system/sw/bin/systemd-run -E LOCALE_ARCHIVE -E NIXOS_INSTALL_BOOTLOADER= --collect --no-ask-password --pipe --quiet --same-dir --service-type=exec --unit=nixos-rebuild-switch-to-configuration --wait /nix/store/*/bin/switch-to-configuration switch";
              options = [ "NOPASSWD" ];
            }
          ];
        }
      ];
    };
  };
}
