{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.amd;
in
with lib;
{
  options = {
    forge.system.amd = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable amd configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pkgs.amdgpu_top
    ];

    programs.ryzen-monitor-ng = {
      enable = true;
    };
    systemd.services.ryzen-monitor = {
      description = "ryzen_monitor";
      after = [ "network.target" ];
      startLimitIntervalSec = 0;
      serviceConfig = {
        Type = "simple";
        Restart = "always";
        RestartSec = 20;
        User = "root";
        ExecStart = "${pkgs.ryzen-monitor-ng}/bin/ryzen_monitor -e/tmp/ryzen_monitor_export";
        SyslogIdentifier = "ryzen_monitor";
        LogLevelMax = "err";
      };
      wantedBy = [ "multi-user.target" ];
    };
  };
}
