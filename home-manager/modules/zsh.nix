{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;
    enableCompletion = true;

    initContent = ''
      ulimit -n 8192 2>/dev/null

      # Highlight Color Setting
      zstyle ':autosuggestions:*' highlight-style 'fg=#7aa2f7'

      zstyle ':completion:*' menu select
      zstyle ':completion:*' format $'\e[2;37mCompleting %d\e[m'

      source ${config.xdg.configHome}/zsh/functions.zsh
    '';
  };

  programs.sheldon = {
    enable = true;
    settings = {
      plugins = {
        zsh-autosuggestions = {
          local = "${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions";
          use = [ "*.plugin.zsh" ];
        };
        zsh-abbr = {
          local = "${pkgs.zsh-abbr}/share/zsh/zsh-abbr";
          use = [ "*.plugin.zsh" ];
        };
        zsh-syntax-highlighting = {
          local = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting";
          use = [ "*.plugin.zsh" ];
        };
      };
    };
  };

  programs.carapace = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    tmux = {
      enableShellIntegration = true;
      shellIntegrationOptions = [ "-p 50%" ];
    };
  };

  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };

  home.sessionPath = [
    "${config.home.homeDirectory}/bin"
    "${config.home.homeDirectory}/.moon/bin"
  ];

  xdg.configFile."zsh-abbr/user-abbreviations".text = ''
    abbr "cdev"="podman run --rm -it -v $PWD:/work -v "$HOME/Documents/programing/Cpp/podman/bashrc":/root/.bashrc:ro -w /work cpp-toolbox:ubuntu2404 bash"
    abbr "l"="eza -F --git --icons"
    abbr "lg"="lazygit"
    abbr "ll"="eza -al --git --icons"
  '';

  xdg.configFile."zsh/functions.zsh".source = ../zsh/functions.zsh;
}
