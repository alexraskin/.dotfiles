{
  description = "My system configuration";
  inputs = {
    # monorepo w/ recipes ("derivations")
    nixpkgs.url = "github:nixos/nixpkgs/nixpkgs-unstable";

    # manages configs
    home-manager.url = "github:nix-community/home-manager/master";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    # system-level software and settings (macOS)
    darwin.url = "github:lnl7/nix-darwin";
    darwin.inputs.nixpkgs.follows = "nixpkgs";

    # declarative homebrew management
    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs =
    { self, ... }@inputs:
    let
      mkSystem = import ./lib/mkSystem.nix { inherit inputs self; };
    in
    {
      darwinConfigurations."mba" = mkSystem "mba" {
        system = "aarch64-darwin";
        user = "alex";
        hostname = "alexs-mba";
      };
    };
}
