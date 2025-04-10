{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.system.pipedream;
  pipedream = pkgs.stdenv.mkDerivation {
    name = "pipedream";
    version = "latest";
    src = pkgs.fetchurl {
      url = "https://cli.pipedream.com/linux/amd64/latest/pd.zip";
      sha256 = "sha256-jmOBpIZHvotrAwlvwlfgzI00i0ltttq8qJgH6MEavSg=";
    };
    nativeBuildInputs =  [
      pkgs.unzip
      pkgs.autoPatchelfHook # https://nixos.wiki/wiki/Packaging/Binaries#Using_AutoPatchelfHook
    ];
    installPhase = ''
      install -m755 -D pd $out/bin/pd
    '';

    # Work around the "unpacker appears to have produced no directories" error,
    # which happens when an archive does not have a subdirectory.
    setSourceRoot = "sourceRoot=`pwd`";
  };
in
with lib;
{
  options = {
    forge.system.pipedream = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable pipedream configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    environment.systemPackages = [
      pipedream
    ];
  };
}
