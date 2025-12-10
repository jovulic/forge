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
      (unstablepkgs.gemini-cli.overrideAttrs (
        final: prev:
        let
          version = "0.20.0";
          src = prev.src.override {
            tag = "v${final.version}";
            hash = "sha256-6+fT9/npYrngAPeAP7pA6DYNuCVWm1lKpSVP4Ux4ddw=";
          };
          npmDeps = prev.npmDeps.overrideAttrs (_: {
            inherit version;
            inherit src;
            outputHash = "sha256-wbr/9IitwQxBVFskCyGZfWy6FmIGZAVYLbF/sMJ2X+s=";
          });
        in
        {
          inherit version;
          inherit src;
          inherit npmDeps;
        }
      ))
    ];
  };
}
