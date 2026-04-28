{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # zsh-autocomplete manages compinit internally; skip home-manager's default call
    enableCompletion = false;

    plugins = [
      {
        name = "zsh-autosuggestions";
        src = pkgs.zsh-autosuggestions;
        file = "share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.plugin.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.plugin.zsh";
      }
      {
        name = "zsh-autocomplete";
        src = pkgs.zsh-autocomplete;
        file = "share/zsh-autocomplete/zsh-autocomplete.plugin.zsh";
      }
      {
        # zsh-abbr must be loaded after compinit; zsh-autocomplete (above) calls
        # compinit when sourced, so loading abbr last satisfies that requirement.
        name = "zsh-abbr";
        src = pkgs.zsh-abbr;
        file = "share/zsh/zsh-abbr/zsh-abbr.plugin.zsh";
      }
    ];

    initContent = ''
      ulimit -n 8192 2>/dev/null

      # Highlight Color Setting
      zstyle ':autosuggestions:*' highlight-style 'fg=#7aa2f7'

      source ${config.xdg.configHome}/zsh/functions.zsh
    '';
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
