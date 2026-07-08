{
  nixpkgs,
  lanzaboote,
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
    lanzaboote.nixosModules.lanzaboote
    (
      { pkgs, lib, ... }:
      {
        environment.systemPackages = [
          # For debugging and troubleshooting Secure Boot.
          pkgs.sbctl
        ];

        # Lanzaboote currently replaces the systemd-boot module.
        # This setting is usually set to true in configuration.nix
        # generated at installation time. So we force it to false
        # for now.
        boot.loader.systemd-boot.enable = lib.mkForce false;

        boot.lanzaboote = {
          enable = true;
          pkiBundle = "/var/lib/sbctl";
        };
      }
    )
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
        modulesPath,
        config,
        ...
      }:
      {
        imports = [
          (modulesPath + "/installer/scan/not-detected.nix")
          ../../forge.nix
        ];

        # ISSUE(ethernet): Random disconnects.
        # Resolved by disabling EEE (energy saving mode) using the following command.
        # # ethforge --set-eee enp6s0 eee off
        # You can view the current configuration with the following command.
        # $ ethforge --show-eee enp6s0

        boot.kernelPatches = [
          # We apply this revert to fix a random hang that happens on linux
          # kernel 6.12.30.
          #
          # commit: https://github.com/torvalds/linux/commit/468034a06a6e8043c5b50f9cd0cac730a6e497b5
          # source: https://gitlab.freedesktop.org/drm/amd/-/issues/4238
          # fixed: >=6.15.2 and >=6.12.33
          # {
          #   name = "amdgpu-revert";
          #   patch = ../../patches/amdgpu_revert.patch;
          # }
        ];

        services.scx = {
          enable = true;
          scheduler = "scx_lavd";
        };

        hardware = {
          enableRedistributableFirmware = true;
          cpu.amd = {
            updateMicrocode = true;
          };
          bluetooth = {
            enable = true;
          };
        };

        forge = {
          system = {
            time.timezone = "Australia/Brisbane";
            boot = {
              luksDevice = "/dev/disk/by-uuid/6ec70204-b630-459a-9ed0-f2f9acba7314";
              initrdAvailableKernelModules = [
                "nvme"
                "xhci_pci"
                "ahci"
                "usbhid"
                "usb_storage"
                "sd_mod"
              ];
              initrdKernelModules = [ "dm-snapshot" ];
              extraModulePackages = [
                config.boot.kernelPackages.zenpower
                config.boot.kernelPackages.nct6687d
              ];
              kernelModules = [
                "kvm-amd"
                "amdgpu"
                "nct6687d"
                "zenpower"
                "nct6775"
              ];
              blacklistedKernelModules = [ "k10temp" ];
              rootDevice = "/dev/disk/by-uuid/03490959-5dcc-4779-852f-a10aa42aed5b";
              bootDevice = "/dev/disk/by-uuid/2320-AFC6";
            };
            network = {
              hostName = "licious";
            };
            alvr.enable = true;
            corectrl.enable = true;
            amd.enable = true;
            aws.enable = false;
            corsair.enable = true;
            lllm.enable = true;
            light.enable = false;
            steam.enable = true;
            wowup.enable = true;
            virtualgl.enable = true;
          };
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
