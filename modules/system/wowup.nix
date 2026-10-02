{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.wowup;

  # https://github.com/NixOS/nixpkgs/blob/nixos-26.05/pkgs/by-name/wo/wowup-cf/package.nix
  wowup-cf =
    let
      pname = "wowup-cf";
      version = "2.24.0-beta.6";

      src = pkgs.fetchurl {
        url = "https://github.com/WowUp/WowUp.CF/releases/download/v${version}/WowUp-CF-${version}.AppImage";
        hash = "sha256-TZ5b/DfVkEh9MsrBi2M/0dAPE1Tfd+zzquRXwprtLqQ=";
      };

      appimageContents = pkgs.appimageTools.extractType1 { inherit pname version src; };
    in
    pkgs.appimageTools.wrapType1 {
      inherit pname version src;

      extraInstallCommands = ''
        install -m 444 -D ${appimageContents}/${pname}.desktop -t $out/share/applications
        substituteInPlace $out/share/applications/${pname}.desktop \
          --replace 'Exec=AppRun' 'Exec=${pname}'
        cp -r ${appimageContents}/usr/share/icons $out/share
      '';
    };
in
with lib;
{
  options = {
    forge.system.wowup = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable wowup configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      wowup-cf
    ];
  };
}
