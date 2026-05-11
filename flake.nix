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
  };

  outputs =
    {
      self,
      nixpkgs,
      home-manager,
      nix-darwin,

      rust-overlay,
      ...
    }:
    let
      overlays = [
        rust-overlay.overlays.default
        (import ./overlays)
      ];
      pkgs = import nixpkgs { inherit overlays; };
    in
    {
      darwinConfigurations."TY" = nix-darwin.lib.darwinSystem {
        specialArgs = { inherit self; };
        modules = [
          ./nix-darwin/configuration.nix
          home-manager.darwinModules.home-manager
        ];
      };
    };
}
