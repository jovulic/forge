{
  nixpkgs,
  system,
  unstablepkgs,
  mypkgs,
  ...
}:
nixpkgs.lib.nixosSystem {
  inherit system;
  specialArgs = {
    inherit unstablepkgs mypkgs;
  };
  modules = [
    (
      { mypkgs, ... }:
      {
        nixpkgs.overlays = [
          (import ../../overlays/nix { nix-shell-builtin = mypkgs.nix-shell-builtin; })
        ];
      }
    )
    ../../modules/system
    (
      {
        pkgs,
        modulesPath,
        ...
      }:
      {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          ../../forge.nix
        ];

        hardware = {
          enableRedistributableFirmware = true;
          cpu.intel = {
            updateMicrocode = true;
          };
          bluetooth = {
            enable = true;
          };
        };

        services.tlp = {
          enable = true;
        };
        services.power-profiles-daemon = {
          enable = false;
        };

        forge = {
          system = {
            boot = {
              luksDevice = "/dev/disk/by-uuid/ee8e6e4c-16cf-44fe-ade3-5c126a9a9067";
              initrdAvailableKernelModules = [
                "xhci_pci"
                "vmd"
                "ahci"
                "nvme"
                "usb_storage"
                "sd_mod"
              ];
              initrdKernelModules = [ "dm-snapshot" ];
              kernelModules = [
                "kvm-intel"
              ];
              kernelParams = [
                "nvme_core.default_ps_max_latency_us=0"
                "pcie_aspm=off"
              ];
              rootDevice = "/dev/disk/by-uuid/cd9f846a-12a8-41c0-b327-aba0f0b6fdad";
              bootDevice = "/dev/disk/by-uuid/183B-00D6";
            };
            network = {
              hostName = "expert";
            };
            aws.enable = false;
            openrgb.enable = false;
            steam.enable = true;
            wowup.enable = true;
          };
        };

        # Disable suspend and hibernate as it presently will fail to
        # resume successfully. It sometimes freezes, sometimes
        # starts-up where the root is read-only and the only way to
        # recover is by pressing the power button.
        systemd.targets = {
          sleep.enable = true;
          suspend.enable = false;
          hibernate.enable = false;
          hybrid-sleep.enable = false;
        };

        environment.systemPackages = [ pkgs.tftp-hpa ];
        services.atftpd = {
          enable = true;
        };

        # This value determines the NixOS release from which the default
        # settings for stateful data, like file locations and database versions
        # on your system were taken. It‘s perfectly fine and recommended to leave
        # this value at the release version of the first install of this system.
        # Before changing this value read the documentation for this option
        # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
        system.stateVersion = "22.05"; # Did you read the comment?
      }
    )
  ];
}
