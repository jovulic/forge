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
        final:
        let
          version = "0.21.1";
          src = final.src.override {
            tag = "v${version}";
            hash = "sha256-WhQbEgr1NhReexVbCxOv11mcP+gftl1J7/FJVdiADXA=";
          };
          npmDeps = unstablepkgs.fetchNpmDeps {
            inherit src;
            hash = "sha256-Q6mtA+Y3k4VoazJ4+uKIFbaC/lUTQFSpXxfXoP7i6Lc=";
          };
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
