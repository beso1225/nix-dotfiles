{
  description = "Home Manager configuration of yutarotakagi";

  inputs = {
    # Specify the source of Home Manager and Nixpkgs.
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";
    rust-overlay = {
      url = "github:oxalica/rust-overlay/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
    pkfire.url = "github:mizchi/pkfire";
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,
      nix-homebrew,

      rust-overlay,
      pkfire,
      ...
    }:
    let
      sharedOverlays = [
        (_: prev: {
          direnv = prev.direnv.overrideAttrs (_: {
            doCheck = false;
          });
        })
        rust-overlay.overlays.default
        (import ./nix/overlays)
      ];
    in
    {

      darwinConfigurations."TY" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self pkfire; };
        modules = [
          { nixpkgs.overlays = sharedOverlays; }
          ./nix/darwin/configuration.nix
          home-manager.darwinModules.home-manager
          nix-homebrew.darwinModules.nix-homebrew
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit pkfire; };
            home-manager.users."yutarotakagi" = ./nix/home/default.nix;
          }
        ];
      };
    };
}
