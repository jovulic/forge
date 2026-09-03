{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.dircolors;
in
with lib;
{
  options = {
    forge.home.dircolors = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable clean, readable dircolors.";
      };
    };
  };

  config = mkIf cfg.enable {
    programs.dircolors = {
      enable = true;
      enableFishIntegration = true;
      settings = {
        # Use Bold Cyan (01;36) for other-writable (ow) and Bold Blue (01;34)
        # for sticky other-writable (tw)
        OTHER_WRITABLE = "01;36";
        STICKY_OTHER_WRITABLE = "01;34";
      };
    };
  };
}
