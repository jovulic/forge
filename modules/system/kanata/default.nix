{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.kanata;

  # Define the auto-switcher package in a let-binding to avoid duplication
  kanata-auto-pkg = pkgs.writeShellApplication {
    name = "kanata-auto";
    runtimeInputs = with pkgs; [ sway jq netcat ];
    text = builtins.readFile ./kanata-auto.sh;
  };
in
with lib;
{
  options = {
    forge.system.kanata = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable kanata configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.kanata
      kanata-auto-pkg
    ];

    environment.etc."kanata/config.kbd".source = ./config.kbd;

    # Create a kanata group to allow non-root users (like the automator) to read/write if necessary
    users.groups.kanata = {};

    # Setup the Kanata systemd service
    systemd.services.kanata = {
      description = "Kanata keyboard remapper";
      wantedBy = [ "multi-user.target" ];
      after = [ "network.target" ];
      serviceConfig = {
        ExecStart = "${pkgs.kanata}/bin/kanata --cfg /etc/kanata/config.kbd --port 10000";
        Restart = "always";
        RestartSec = "3";
        # Kanata needs uinput and input access to read/write hardware
        SupplementaryGroups = [ "input" "uinput" ];
      };
    };

    # Set up the automator as a system-defined, user-level systemd service
    # This naturally integrates with the graphical user session (Sway)
    systemd.user.services.kanata-auto = {
      description = "Kanata Auto-Switcher Daemon";
      wantedBy = [ "graphical-session.target" ];
      after = [ "graphical-session-pre.target" ];
      partOf = [ "graphical-session.target" ];
      serviceConfig = {
        ExecStart = "${kanata-auto-pkg}/bin/kanata-auto";
        Restart = "always";
        RestartSec = "3";
      };
    };
    
    # Ensure uinput is available
    hardware.uinput.enable = true;
  };
}