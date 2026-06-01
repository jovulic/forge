{ pkgs, ... }:
{
  environment.systemPackages = [
    pkgs.nix-search-cli
    pkgs.manix
    (pkgs.writeShellApplication {
      name = "forge";
      runtimeInputs = [
        pkgs.nix-search-cli
        pkgs.manix
        pkgs.fzf
      ];
      text = builtins.readFile ./forge.sh;
      bashOptions = [
        "errexit"
        "pipefail"
      ];
    })
  ];
}
