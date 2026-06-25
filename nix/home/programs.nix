{
  pkgs,
  ...
}:
{
  # Let Home Manager install and manage itself.
  programs.home-manager.enable = true;

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      add_newline = false;
      character = {
        success_symbol = "[❯](green)";
        error_symbol = "[❯](red)";
      };
      git_branch = {
        symbol = " ";
        style = "bold yellow";
      };
      git_status.disabled = false;
      package.disabled = true;
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    baseIndex = 1;
    historyLimit = 100000;
    prefix = "C-a";
    terminal = "tmux-256color";

    extraConfig = ''
      # split panes using | and -
      bind | split-window -h -c "#{pane_current_path}"
      bind - split-window -v -c "#{pane_current_path}"

      # move panes like vim
      bind h select-pane -L
      bind j select-pane -D
      bind k select-pane -U
      bind l select-pane -R

      # resize panes like vim
      bind -r H resize-pane -L 5
      bind -r J resize-pane -D 5
      bind -r K resize-pane -U 5
      bind -r L resize-pane -R 5
    '';

    plugins = with pkgs; [
      tmuxPlugins.resurrect
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
    ];
  };

  # Sheldon manages zsh plugins (autosuggestions, syntax-highlighting, zsh-abbr).
  # Autocompletion is handled by nix enableCompletion + carapace instead.
  programs.sheldon = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      shell = "zsh";
      plugins = {
        zsh-autosuggestions.github = "zsh-users/zsh-autosuggestions";
        zsh-syntax-highlighting.github = "zsh-users/zsh-syntax-highlighting";
        zsh-abbr.github = "olets/zsh-abbr";
      };
    };
  };
}
