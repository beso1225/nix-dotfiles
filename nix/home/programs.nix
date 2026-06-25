{
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
