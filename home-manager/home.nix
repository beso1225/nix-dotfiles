{

  config,
  pkgs,
  ...
}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  dotfilesDir = "${config.home.homeDirectory}/ghq/github.com/beso1225/nix-dotfiles";
  rustToolchain = pkgs.rust-bin.stable.latest.default.override {
    extensions = [ "llvm-tools-preview" ];
  };

  tex = pkgs.texlive.combine {
    inherit (pkgs.texlive)
      scheme-medium
      luatexja
      jsclasses

      # Additional packages not included in the above schemes
      silence
      ;
  };
in
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
    nixfmt
    nixd

    direnv
    nix-direnv

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
    ghq
    uv
    chezmoi

    # rust tools
    rustToolchain
    cargo-binutils
    sqlx-cli
    cargo-compete
    mini-redis

    # C/C++ tools
    gcc
    cmake
    ninja

    # TeX
    tex
    biber
    ghostscript
    poppler-utils
  ];

  home.sessionVariables = {
    FZF_TMUX = "1";
    FZF_TMUX_OPTS = "-p 50%";
    CARAPACE_BRIDGES = "zsh";
  };

  home.sessionPath = [
    "$HOME/bin"
    "/etc/profiles/per-user/yutarotakagi/bin"
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
      abbr "t"="eza -F --tree --icons"
      abbr "ta"="eza -aF --tree --icons --git-ignore"
      abbr "tl"="eza -alF --tree --git --icons --git-ignore"
      abbr "l"="eza -F --icons"
      abbr "la"="eza -aF --icons"
      abbr "ll"="eza -al --git --icons"
      abbr "lg"="lazygit"
    '';

    # Neovim configuration
    ".config/nvim".source = mkOutOfStoreSymlink "${dotfilesDir}/home-manager/nvim";

    # Chezmoi configuration
    ".config/chezmoi".source = mkOutOfStoreSymlink "${dotfilesDir}/home-manager/chezmoi";
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
        symbol = " ";
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
    options = [
      "--cmd"
      "cd"
    ];
  };

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };

  # Sheldon manages zsh plugins (autosuggestions, syntax-highlighting, zsh-abbr).
  # Autocompletion is handled by nix enableCompletion + carapace instead.
  programs.sheldon = {
    enable = true;
    enableZshIntegration = true;
    settings = {
      shell = "zsh";
      plugins = {
        zsh-autosuggestions = {
          github = "zsh-users/zsh-autosuggestions";
        };
        zsh-syntax-highlighting = {
          github = "zsh-users/zsh-syntax-highlighting";
        };
        zsh-abbr = {
          github = "olets/zsh-abbr";
        };
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

      export PATH="$HOME/bin:$PATH"

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

      # direnv setup
      eval "$(direnv hook zsh)"

      # ghq setup
      ghq() {
        if [ $# -eq 0 ]; then
          local repo_path
          repo_path=$(command ghq list | fzf --height 40% --reverse)
          if [[ -n "$repo_path" ]]; then
            cd "$(command ghq root)/$repo_path"
          fi
        else
          command ghq "$@"
        fi
      }

      ghq-fzf_change_directory() {
        local src=$(command ghq list | fzf --preview "eza -l -g -a --icons $(command ghq root)/{} | tail -n+4 | awk '{print \$6\"/\"\$8\" \"\$9 \" \" \$10}'")
        if [ -n "$src" ]; then
          BUFFER="cd $(command ghq root)/$src"
          zle accept-line
        fi
        zle -R -c
      }
      zle -N ghq-fzf_change_directory
      bindkey '^f' ghq-fzf_change_directory
    '';
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
}
