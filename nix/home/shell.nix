{
  config,
  ...
}:
let
  inherit (config.lib.file) mkOutOfStoreSymlink;
  dotfilesDir = "${config.home.homeDirectory}/ghq/github.com/beso1225/nix-dotfiles";
in
{
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
    ".gitconfig".source = ../../home-manager/git/.gitconfig;

    # Custom zsh functions loaded via fpath
    ".config/zsh/functions/ccnew".source = ../../home-manager/zsh/functions/ccnew;
    ".config/zsh/functions/y".source = ../../home-manager/zsh/functions/y;

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
      export EDITOR=nvim
      export VISUAL=nvim

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
}
