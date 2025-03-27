{
  config,
  options,
  lib,
  ...
}:
let
  cfg = config.forge.system.boot;
in
with lib;
{
  options = {
    forge.system.boot = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable core configuration.";
      };
      luksDevice = mkOption {
        type = types.str;
        example = "/dev/disk/by-uuid/6f4d9833-28a8-4762-af5f-f189538920c5";
        description = ''
          Path of the underlying encrypted block device.
        ''; # https://github.com/NixOS/nixpkgs/blob/nixos-22.11/nixos/modules/system/boot/luksroot.nix#L573
      };
      initrdAvailableKernelModules = mkOption {
        type = types.listOf types.str;
        example = [
          "xhci_pci"
          "ahci"
          "nvme"
          "usb_storage"
          "usbhid"
          "sd_mod"
        ];
        description = options.boot.initrd.availableKernelModules.description;
      };
      initrdKernelModules = mkOption {
        type = types.listOf types.str;
        example = [ "dm-snapshot" ];
        description = options.boot.initrd.kernelModules.description;
      };
      kernelModules = mkOption {
        type = types.listOf types.str;
        example = [ "kvm-intel" ];
        description = options.boot.kernelModules.description;
      };
      kernelParams = mkOption {
        type = types.listOf types.str;
        example = [ "pcie_aspm=off" ];
        description = options.boot.kernelParams.description;
        default = [ ];
      };
      rootDevice = mkOption {
        type = types.str;
        example = "/dev/disk/by-uuid/7f0ec4fc-5456-41a8-a0ae-ea9185ffcea8";
        description = "Path to root device.";
      };
      bootDevice = mkOption {
        type = types.str;
        example = "/dev/disk/by-uuid/4D5C-3C88";
        description = "Path to boot device.";
      };
    };
  };
  config = mkIf cfg.enable {
    boot = {
      loader = {
        systemd-boot.enable = true;
        efi.canTouchEfiVariables = true;
      };
      initrd = {
        luks = {
          fido2Support = true;
          devices = {
            luksroot = {
              device = cfg.luksDevice;
              preLVM = true;
              allowDiscards = true;
              fido2 = {
                credential = "8a89567fc1bbcdcb6cb7382a936589c0e114bd65e844187dc06f1666e935e86371ecf41784f3e899221b131336c1b1c5";
                passwordLess = true;
              };
            };
          };
        };
        availableKernelModules = cfg.initrdAvailableKernelModules;
        kernelModules = cfg.initrdKernelModules;
      };
      # kernelPackages = pkgs.linuxPackages_5_19;
      kernelModules = cfg.kernelModules;
      extraModulePackages = [ ];
      # extraModprobeConfig = ''
      #   options iwlwifi power_save=0
      #   options iwlmvm power_scheme=1
      # '';
      kernelParams = cfg.kernelParams;
      supportedFilesystems = [ "ntfs" ];
    };

    fileSystems."/" = {
      device = cfg.rootDevice;
      fsType = "ext4";
      options = [
        "noatime"
        "nodiratime"
        "discard"
      ];
    };

    fileSystems."/boot" = {
      device = cfg.bootDevice;
      fsType = "vfat";
    };

    swapDevices = [ ];
  };
}
