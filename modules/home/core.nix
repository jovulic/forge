{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.core;
in
with lib;
{
  options = {
    forge.home.core = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable core configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # Check for nixpkgs and home-manager version mismatch.
    home.enableNixpkgsReleaseCheck = true;

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "me";
    home.homeDirectory = "/home/me";
    home.sessionPath = [ ];
    home.sessionVariables = {
      EDITOR = "nvim";
      TERMINAL = "foot";
      BROWSER = "google-chrome-stable";
      READER = "zathura";
      FILE = "n";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    # Generally useful but also necessary for manix to work with home-manager.
    # https://github.com/nix-community/manix/issues/18
    manual.json.enable = true;
  };
}
