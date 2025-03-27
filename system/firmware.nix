{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.system.firmware;
in
with lib;
{
  options = {
    forge.system.firmware = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable firmware configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    # $ fwupdmgr get-updates
    # $ fwupdmgr update
    services.fwupd = {
      enable = true;
    };

    # BIOS updates...
    # https://www.asus.com/Laptops/For-Work/ExpertBook/ExpertBook-B1-B1400/HelpDesk_BIOS/?model2Name=ExpertBook-B1-B1400CEAE
    # B1400CEAEY
    # # dmidecode -s bios-version
  };
}
