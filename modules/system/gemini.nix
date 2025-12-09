{
  config,
  lib,
  unstablepkgs,
  ...
}:
let
  cfg = config.forge.system.gemini;
in
with lib;
{
  options = {
    forge.system.gemini = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable gemini configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      (unstablepkgs.gemini-cli-bin.overrideAttrs rec {
        version = "0.19.4";
        src = unstablepkgs.fetchurl {
          url = "https://github.com/google-gemini/gemini-cli/releases/download/v${version}/gemini.js";
          hash = "sha256-qOP+zt7iwBnNUkvCPmHO4DoYs8kJh1hvGeu0IbEA/E0=";
        };
      })
    ];
  };
}
