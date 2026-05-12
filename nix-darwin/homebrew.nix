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
    };
    global.autoUpdate = false;

    # List of Homebrew packages to be installed.
    brews = [
      "arduino-cli"
      "gnuplot"
      "qemu"
    ];
    casks = [
      "copilot-cli"
    ];
  };
}
