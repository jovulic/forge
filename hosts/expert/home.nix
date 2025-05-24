{
  pkgs,
  unstablepkgs,
  mypkgs,
  nix,
  name,
  home-manager,
  ...
}:
home-manager.lib.homeManagerConfiguration {
  inherit pkgs;
  modules = [
    {
      _module.args = { inherit unstablepkgs mypkgs nix; };
    }
    ../../modules/home
    (
      { options, ... }:
      {
        forge = {
          home = {
            openrgb.enable = false;
            sway = {
              enable = true;
              name = name;
            };
            waybar = {
              enable = true;
              name = name;
            };
            kanshi = {
              enable = true;
              name = name;
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
}
