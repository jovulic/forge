{
  nixpkgs,
  system,
  unstablepkgs,
  mypkgs,
  nix,
  ...
}:
nixpkgs.lib.nixosSystem {
  inherit system;
  modules = [
    {
      _module.args = { inherit unstablepkgs mypkgs nix; };
    }
    ../../modules/system
    (
      {
        modulesPath,
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
          # We apply a kernel patch to allow any application to create
          # high priority contexts (such as steam). It does this by
          # patching the kernel to ignore process privileges.
          #
          # source: https://wiki.nixos.org/wiki/VR#SteamVR
          {
            name = "amdgpu-ignore-ctx-privileges";
            patch = ../../patches/cap_sys_nice_begone.patch;
          }
          # We apply this revert to fix a random hang that happens on linux
          # kernel 6.12.30.
          #
          # commit: https://github.com/torvalds/linux/commit/468034a06a6e8043c5b50f9cd0cac730a6e497b5
          # source: https://gitlab.freedesktop.org/drm/amd/-/issues/4238
          {
            name = "amdgpu-revert";
            patch = ../../patches/amdgpu_revert.patch;
          }
        ];

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
            boot = {
              luksDevice = "/dev/disk/by-uuid/6f4d9833-28a8-4762-af5f-f189538920c5";
              initrdAvailableKernelModules = [
                "nvme"
                "xhci_pci"
                "ahci"
                "usbhid"
                "usb_storage"
                "sd_mod"
              ];
              initrdKernelModules = [ "dm-snapshot" ];
              kernelModules = [
                "kvm-amd"
                "amdgpu"
              ];
              rootDevice = "/dev/disk/by-uuid/7f0ec4fc-5456-41a8-a0ae-ea9185ffcea8";
              bootDevice = "/dev/disk/by-uuid/4D5C-3C88";
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
