{
  config,
  lib,
  pkgs,
  ...
}:
let
  cfg = config.forge.home.fish;
in
with lib;
{
  options = {
    forge.home.fish = {
      enable = mkOption {
        type = types.bool;
        default = true;
        description = "Enable fish configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    programs.fish = {
      enable = true;
      interactiveShellInit = ''
        set fish_greeting

        # Migrate old Tide configuration variables if they exist.
        if set -q tide_left_prompt_items
            set -U tide_left_prompt_items (string replace -m 1 virtual_env python $tide_left_prompt_items)
            set -U tide_left_prompt_items (string replace -m 1 chruby ruby $tide_left_prompt_items)
        end
        if set -q tide_right_prompt_items
            set -U tide_right_prompt_items (string replace -m 1 virtual_env python $tide_right_prompt_items)
            set -U tide_right_prompt_items (string replace -m 1 chruby ruby $tide_right_prompt_items)
        end
      ''
      + optionalString (config.forge.home.terminal.name == "foot") ''

        # Mark prompts to allow foot terminal to jump between prompts.
        function mark_prompt_start --on-event fish_prompt
            echo -en "\e]133;A\e\\"
        end
      '';
      plugins = [
        {
          name = "tide";
          src = pkgs.fetchFromGitHub {
            owner = "IlanCosman";
            repo = "tide";
            rev = "v6.2.0";
            sha256 = "sha256-1ApDjBUZ1o5UyfQijv9a3uQJ/ZuQFfpNmHiDWzoHyuw=";
          };
        }
        {
          name = "fzf";
          src = pkgs.fetchFromGitHub {
            owner = "PatrickF1";
            repo = "fzf.fish";
            rev = "v11.0";
            sha256 = "sha256-H7HgYT+okuVXo2SinrSs+hxAKCn4Q4su7oMbebKd/7s=";
          };
        }
        {
          name = "done";
          src = pkgs.fetchFromGitHub {
            owner = "franciscolourenco";
            repo = "done";
            rev = "1.21.1";
            sha256 = "sha256-GZ1ZpcaEfbcex6XvxOFJDJqoD9C5out0W4bkkn768r0=";
          };
        }
        {
          name = "forgit";
          src = pkgs.fetchFromGitHub {
            owner = "wfxr";
            repo = "forgit";
            rev = "26.09.1";
            sha256 = "sha256-02w+BGrRDEFWLtH6tniiTgs+FHmghiHn9FMxO+U4wrI=";
          };
        }
      ];
    };

    home.file = {
      ".config/fish/functions/_abbr_kube.fish" = {
        source = ./_abbr_kube.fish;
      };
      ".config/fish/functions/_abbr_mount.fish" = {
        source = ./_abbr_mount.fish;
      };
      ".config/fish/functions/_abbr_vim.fish" = {
        source = ./_abbr_vim.fish;
      };
      ".config/fish/functions/fish_user_key_bindings.fish" = {
        source = ./fish_user_key_bindings.fish;
      };
    };
  };
}
