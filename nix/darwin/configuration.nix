{
  self,
  ...
}:
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  system = {
    # Please read the documentation of stateVersion before changing this.
    stateVersion = 6;

    # setting to record of commit hash of the configuration
    configurationRevision = self.rev or self.dirtyRev or null;

    primaryUser = "yutarotakagi";
  };

  # Set the home directory
  users.users."yutarotakagi".home = "/Users/yutarotakagi";

  # import the Nix Homebrew module to manage Homebrew packages.
  imports = [ ./homebrew.nix ];

  # Disable the management of the Nix by nix-darwin, since Home Manager will manage it.
  nix.enable = false;

  # Set the default shell to zsh
  programs.zsh.enable = true;

  # Enable Touch ID authentication for sudo and reattach to the session after authentication.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    reattach = true;
  };

  # macOS defaults
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      "com.apple.mouse.tapBehavior" = 1;
    };
    finder = {
      AppleShowAllExtensions = true;
      AppleShowAllFiles = true;
      FXEnableExtensionChangeWarning = false;
      ShowPathbar = true;
    };
    dock = {
      autohide = true;
      show-recents = false;
      show-process-indicators = true;
    };
  };
}
