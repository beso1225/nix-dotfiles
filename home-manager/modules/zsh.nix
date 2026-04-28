{ config, pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    # zsh-autocomplete manages compinit internally; skip home-manager's default call
    enableCompletion = false;

    initContent = ''
      ulimit -n 8192 2>/dev/null

      # Highlight Color Setting
      zstyle ':autosuggestions:*' highlight-style 'fg=#7aa2f7'

      source ${config.xdg.configHome}/zsh/functions.zsh
    '';
  };

  programs.sheldon = {
    enable = true;
  };

  # plugins.toml is written directly to control load order:
  # zsh-abbr must be sourced after zsh-autocomplete (which calls compinit).
  # Nix attrsets are sorted alphabetically, so programs.sheldon.plugins would
  # load zsh-abbr before zsh-autocomplete — writing the file manually avoids this.
  xdg.configFile."sheldon/plugins.toml".text = ''
    [plugins.zsh-autosuggestions]
    local = "${pkgs.zsh-autosuggestions}/share/zsh/plugins/zsh-autosuggestions"
    use = ["*.plugin.zsh"]

    [plugins.zsh-syntax-highlighting]
    local = "${pkgs.zsh-syntax-highlighting}/share/zsh-syntax-highlighting"
    use = ["*.plugin.zsh"]

    # zsh-autocomplete calls compinit when sourced
    [plugins.zsh-autocomplete]
    local = "${pkgs.zsh-autocomplete}/share/zsh-autocomplete"
    use = ["*.plugin.zsh"]

    # zsh-abbr must be loaded after compinit
    [plugins.zsh-abbr]
    local = "${pkgs.zsh-abbr}/share/zsh/zsh-abbr"
    use = ["*.plugin.zsh"]
  '';

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
