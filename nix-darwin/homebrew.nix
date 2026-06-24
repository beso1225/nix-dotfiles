{
  nix-homebrew,
  ...
}:
{
  nix-homebrew = {
    enable = true;
    user = "yutarotakagi";
    enableRosetta = false;
    autoMigrate = true;
  };

  homebrew = {
    enable = true;
    user = "yutarotakagi";
    # brew update: update the formula, but not install,
    # darwin-rebuild switch: install the latest version of the formula.
    onActivation = {
      upgrade = true;
      autoUpdate = false;
      # cleanup = true; # In the future, we may want to enable this to remove old versions of packages.
    };
    global.autoUpdate = false;

    # List of Homebrew packages to be installed.
    brews = [
      "arduino-cli"
      "apm"
      "pkfire"
      "qemu"
    ];
    casks = [
      "copilot-cli"
      "codex"
    ];
  };
}
