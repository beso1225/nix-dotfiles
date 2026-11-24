{
  self,
  lib,
  ...
}:
{
  nixpkgs.hostPlatform = "aarch64-darwin";
  nixpkgs.config.allowUnfreePredicate = pkg: lib.getName pkg == "obsidian";
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

  # Set the GUI session environment on every login.
  launchd.user.agents.t3code-environment.serviceConfig = {
    Label = "com.yutarotakagi.t3code-environment";
    ProgramArguments = [
      "/bin/launchctl"
      "setenv"
      "T3CODE_TELEMETRY_ENABLED"
      "false"
      "T3CODE_OTEL_SDK_DISABLED"
      "true"
    ];
    RunAtLoad = true;
  };

  # Block the remaining cross-sign root used by the compromised eMudhra intermediates.
  # NSS already excludes emSign ECC Root CA - G3; blacklisting an absent root fails the build.
  security.pki.caCertificateBlacklist = [
    "Comodo AAA Services root"
  ];

  # Enable Touch ID authentication for sudo and reattach to the session after authentication.
  security.pam.services.sudo_local = {
    touchIdAuth = true;
    watchIdAuth = true;
    reattach = true;
  };

  # macOS defaults
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = null;
      "com.apple.mouse.tapBehavior" = 1;

      # menubar space size
      NSStatusItemSelectionPadding = 6;
      NSStatusItemSpacing = 6;
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
