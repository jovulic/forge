{
  config,
  lib,
  ...
}:
let
  cfg = config.forge.home.taskwarrior;
in
with lib;
{
  options = {
    forge.home.taskwarrior = {
      enable = mkOption {
        type = types.bool;
        default = false;
        description = "Enable taskwarrior configuration.";
      };
    };
  };
  config = mkIf cfg.enable {
    home.file = {
      ".config/task/taskrc" = {
        text = ''
          # [Created by task 2.6.1 3/6/2022 18:03:51]
          # Taskwarrior program configuration file.
          # For more documentation, see https://taskwarrior.org or try 'man task', 'man task-color',
          # 'man task-sync' or 'man taskrc'

          # Here is an example of entries that use the default, override and blank values
          #   variable=foo   -- By specifying a value, this overrides the default
          #   variable=      -- By specifying no value, this means no default
          #   #variable=foo  -- By commenting out the line, or deleting it, this uses the default

          # You can also refence environment variables:
          #   variable=$HOME/task
          #   variable=$VALUE

          # Use the command 'task show' to see all defaults and overrides

          # Files
          # data.location=/home/me/.task

          # To use the default location of the XDG directories,
          # move this configuration file from ~/.taskrc to ~/.config/task/taskrc and uncomment below

          data.location=~/.local/share/task
          hooks.location=~/.config/task/hooks

          # Color theme (uncomment one to use) #include light-16.theme #include light-256.theme
          #include dark-16.theme
          #include dark-256.theme
          #include dark-red-256.theme
          #include dark-green-256.theme
          #include dark-blue-256.theme
          #include dark-violets-256.theme
          #include dark-yellow-green.theme
          #include dark-gray-256.theme
          #include dark-gray-blue-256.theme
          #include solarized-dark-256.theme
          #include solarized-light-256.theme
          #include no-color.theme

          # Disable nag message.
          nag=""

          # Change default command.
          default.command=list
        '';
      };
    };
  };
}
