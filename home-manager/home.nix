{ config, pkgs, lib, ... }:

{
  # Home Manager needs a bit of information about you and the paths it should
  # manage.
  home.username = "yutarotakagi";
  home.homeDirectory = "/Users/yutarotakagi";

  # This value determines the Home Manager release that your configuration is
  # compatible with. This helps avoid breakage when a new Home Manager release
  # introduces backwards incompatible changes.
  #
  # You should not change this value, even if you update Home Manager. If you do
  # want to update the value, then make sure to first check the Home Manager
  # release notes.
  home.stateVersion = "25.11"; # Please read the comment before changing.

  # The home.packages option allows you to install Nix packages into your
  # environment.
  home.packages = with pkgs; [
    git
    neovim
    eza
    lazygit
    yazi
    just
    cargo-watch
    tree-sitter
    fd
    ripgrep
    bat
    gh
    wget
    # cargo
    # rustc
  ];

  home.sessionVariables = {
    FZF_TMUX = "1";
    FZF_TMUX_OPTS = "-p 50%";
    CARAPACE_BRIDGES = "zsh,fish,bash,inshellisense";
  };

  home.sessionPath = [
    "$HOME/bin"
    "$HOME/.local/bin"
    "$HOME/.moon/bin"
  ];

  home.file = {
    ".gitconfig".source = ./git/.gitconfig;

    # Custom zsh functions loaded via fpath
    ".config/zsh/functions/ccnew".source = ./zsh/functions/ccnew;
    ".config/zsh/functions/y".source = ./zsh/functions/y;

    # zsh-abbr abbreviations (hardcoded in nix)
    ".config/zsh-abbr/user-abbreviations".text = ''
      abbr "cdev"='podman run --rm -it -v $PWD:/work -v "$HOME/Documents/programing/Cpp/podman/bashrc":/root/.bashrc:ro -w /work cpp-toolbox:ubuntu2404 bash'
      abbr "l"="eza -F --git --icons"
      abbr "lg"="lazygit"
      abbr "ll"="eza -al --git --icons"
    '';
  };

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
        symbol = " ";
        style = "bold yellow";
      };
      git_status = {
        disabled = false;
      };
      package = {
        disabled = true;
      };
    };
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd" "cd" ];
  };

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };

  # Sheldon manages zsh plugins (autosuggestions, syntax-highlighting, zsh-abbr).
  # Autocompletion is handled by nix enableCompletion + carapace instead.
  programs.sheldon = {
    enable = true;
    settings = {
      shell = "zsh";
      plugins = {
        zsh-autosuggestions = { github = "zsh-users/zsh-autosuggestions"; };
        zsh-syntax-highlighting = { github = "zsh-users/zsh-syntax-highlighting"; };
        zsh-abbr = { github = "olets/zsh-abbr"; };
      };
    };
  };

  programs.zsh = {
    enable = true;
    # Autosuggestions and syntax-highlighting are managed by sheldon above.
    autosuggestion.enable = false;
    syntaxHighlighting.enable = false;
    enableCompletion = true;

    history = {
      size = 10000;
      save = 10000;
      ignoreDups = true;
      ignoreSpace = true;
      extended = true;
      share = true;
    };

    initContent = ''
      ulimit -n 8192 2>/dev/null
      
      source $HOME/.cargo/env

      # Homebrew setup (macOS)
      if [ -f /opt/homebrew/bin/brew ]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
      fi

      # Load custom zsh functions via fpath
      fpath=($HOME/.config/zsh/functions $fpath)
      autoload -Uz ccnew y

      # Completion styling
      zstyle ':completion:*' menu select
      zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'
      export ZSH_AUTOSUGGEST_HIGHLIGHT_STYLE='fg=#7aa2f7'

      # Useful zsh options
      setopt auto_pushd
      setopt auto_cd
    '';
  };

  programs.tmux = {
    enable = true;
    clock24 = true;
    mouse = true;
    baseIndex = 1;
    historyLimit = 100000;
    prefix = "C-a";

    extraConfig = ''
      # split panes using | and -
      bind | split-window -h
      bind - split-window -v

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

      # set default terminal to tmux-256color
      set -g default-terminal "tmux-256color"
    '';

    plugins = with pkgs; [
      tmuxPlugins.resurrect
      {
        plugin = tmuxPlugins.continuum;
        extraConfig = "set -g @continuum-restore 'on'";
      }
    ];
  };

  home.file.".config/nvim".source =
    config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/nix-dotfiles/home-manager/nvim";
}
