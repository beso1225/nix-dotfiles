{
  description = "Home Manager configuration of yutarotakagi";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs =
    { nixpkgs, home-manager, ... }:
    let
      system = "aarch64-darwin";
      overlays = [ (import ./overlays) ];
      pkgs = import nixpkgs { inherit system overlays; };
    in
    {
      homeConfigurations."yutarotakagi" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;

        # Specify your home configuration modules here, for example,
        # the path to your home.nix.
        modules = [ ./home-manager/home.nix ];

        # Pass the dotfiles directory so home.nix can create out-of-store
        # symlinks (writable) instead of Nix store symlinks (read-only).
        extraSpecialArgs = { dotfilesDir = builtins.toString ./.; };
      };
    };
}
