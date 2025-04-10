{
  description = "Where I go to shape my machines.";

  inputs = {
    nixpkgs.url = "nixpkgs/nixos-24.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable.url = "nixpkgs/nixos-unstable";
    home-manager-unstable = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs-unstable";
    };
  };

  outputs =
    { ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = import inputs.nixpkgs {
        inherit system;
      };
      unstablepkgs = import inputs.nixpkgs-unstable {
        inherit system;
      };
      mypkgs = pkgs.callPackage ./pkgs { };
    in
    {
      devShells.${system}.default =
        let
          ctl = pkgs.writeShellApplication {
            name = "ctl";
            runtimeInputs = [
              pkgs.figlet
            ];
            text = builtins.readFile ./ctl/ctl;
            bashOptions = [
              "errexit"
              "pipefail"
            ];
          };
        in
        pkgs.mkShell {
          packages = [
            pkgs.bashly
            pkgs.figlet
            ctl
          ];
        };
      homeConfigurations = {
        "me@licious" =
          let
            configName = "licious";
          in
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              {
                _module.args = { inherit unstablepkgs mypkgs; };
              }
              ./modules/home
              (
                { ... }:
                {
                  forge = {
                    home = {
                      nix = {
                        package = pkgs.nixVersions.nix_2_26;
                      };
                      sway = {
                        enable = true;
                        name = configName;
                      };
                      waybar = {
                        enable = true;
                        name = configName;
                      };
                      kanshi = {
                        enable = true;
                        name = configName;
                      };
                      plover.enable = false;
                    };
                  };

                  # This value determines the Home Manager release that your
                  # configuration is compatible with. This helps avoid breakage
                  # when a new Home Manager release introduces backwards
                  # incompatible changes.
                  #
                  # You can update Home Manager without changing this value. See
                  # the Home Manager release notes for a list of state version
                  # changes in each release.
                  home.stateVersion = "22.05";
                }
              )
            ];
          };
        "me@expert" =
          let
            configName = "expert";
          in
          inputs.home-manager.lib.homeManagerConfiguration {
            inherit pkgs;
            modules = [
              {
                _module.args = { inherit unstablepkgs mypkgs; };
              }
              ./modules/home
              (
                { options, ... }:
                {
                  forge = {
                    home = {
                      nix = {
                        package = pkgs.nixVersions.nix_2_26;
                      };
                      openrgb.enable = false;
                      sway = {
                        enable = true;
                        name = configName;
                      };
                      waybar = {
                        enable = true;
                        name = configName;
                      };
                      kanshi = {
                        enable = true;
                        name = configName;
                      };
                      plover.enable = false;
                      foot = {
                        settings = options.forge.home.foot.settings.default // {
                          main = {
                            font = "monospace:size=10";
                          };
                        };
                      };
                    };
                  };

                  # This value determines the Home Manager release that your
                  # configuration is compatible with. This helps avoid breakage
                  # when a new Home Manager release introduces backwards
                  # incompatible changes.
                  #
                  # You can update Home Manager without changing this value. See
                  # the Home Manager release notes for a list of state version
                  # changes in each release.
                  home.stateVersion = "22.05";
                }
              )
            ];
          };
      };
      nixosConfigurations = {
        licious =
          let
            pkgs = import inputs.nixpkgs {
              inherit system;
              config = {
                rocmSupport = true;
              };
            };
            unstablepkgs = import inputs.nixpkgs-unstable {
              inherit system;
              # https://github.com/NixOS/nixpkgs/issues/379354
              # Note, unable to build open-webui as pytorch being marked as
              # borken when building with rocm support.
              config = {
                rocmSupport = true;
              };
            };
            mypkgs = pkgs.callPackage ./pkgs {
              config = {
                rocmSupport = true;
              };
            };
          in
          inputs.nixpkgs.lib.nixosSystem {
            inherit system;
            modules = [
              {
                _module.args = { inherit unstablepkgs mypkgs; };
              }
              ./modules/system
              (
                {
                  pkgs,
                  modulesPath,
                  ...
                }:
                {
                  imports = [
                    (modulesPath + "/installer/scan/not-detected.nix")
                    ./forge.nix
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
                      patch = ./patches/cap_sys_nice_begone.patch;
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
                      nix = {
                        package = pkgs.nixVersions.nix_2_26;
                      };
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
          };
        expert = inputs.nixpkgs.lib.nixosSystem {
          inherit system;
          modules = [
            {
              _module.args = { inherit unstablepkgs mypkgs; };
            }
            ./modules/system
            (
              {
                pkgs,
                modulesPath,
                ...
              }:
              {
                imports = [
                  (modulesPath + "/installer/scan/not-detected.nix")
                  ./forge.nix
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
                    nix = {
                      package = pkgs.nixVersions.nix_2_26;
                    };
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
        };
      };
    };
}
