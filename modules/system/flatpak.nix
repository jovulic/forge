{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.flatpak;
in
with lib;
{
  options = {
    forge.system.flatpak = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable flatpak configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    services.flatpak = {
      enable = true;
    };
    # Add flathub remote repository.
    # $ flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    #
    # Something about XDG_DATA_DIRS and shares, if there are issues.
    #
    # Update flatpak packages.
    # $ flatpak updae
    #
    # Search flatpak.
    # $ flatpak search steam
    #
    # Install package.
    # $ flatpak install flathub com.valvesoftware.Steam
  };
}
