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
            rev = "v5.3.0";
            sha256 = "sha256-/r+vaJIQ+yi7YDN7AThRKWDimdDuVmeYcg7t0GzebZE=";
          };
        }
        {
          name = "fzf";
          src = pkgs.fetchFromGitHub {
            owner = "PatrickF1";
            repo = "fzf.fish";
            rev = "v9.0";
            sha256 = "sha256-0rnd8oJzLw8x/U7OLqoOMQpK81gRc7DTxZRSHxN9YlM=";
          };
        }
        {
          name = "done";
          src = pkgs.fetchFromGitHub {
            owner = "franciscolourenco";
            repo = "done";
            rev = "1.16.5";
            sha256 = "sha256-E0wveeDw1VzEH2kzn63q9hy1xkccfxQHBV2gVpu2IdQ=";
          };
        }
        {
          name = "forgit";
          src = pkgs.fetchFromGitHub {
            owner = "wfxr";
            repo = "forgit";
            rev = "3506cfc3655a08f45e991428723d3236d92fe35d";
            sha256 = "sha256-IfyDq2idDkN8GXwTcQ6tOzqnogO+ewDzFLuiyQqxgg4=";
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
