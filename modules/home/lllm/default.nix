{
  config,
  lib,
  mypkgs,
  ...
}:
let
  cfg = config.forge.home.lllm;
in
with lib;
{
  options = {
    forge.home.lllm = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable lllm configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    systemd.user.services = {
      mcp-hub = {
        Install = {
          WantedBy = [ "sway-session.target" ];
        };
        Unit = {
          Description = "MCP Hub Server.";
          BindsTo = "sway-session.target";
          After = "sway-session.target";
        };
        Service = {
          ExecStart = "${mypkgs.mcp-hub}/bin/mcp-hub --port=37373 --config=$${HOME}/.config/mcphub/servers.json";
          RestartSec = 5;
          Restart = "always";
        };
      };
    };
  };
}
