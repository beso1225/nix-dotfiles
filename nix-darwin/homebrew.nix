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
