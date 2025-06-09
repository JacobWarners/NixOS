{
  description = "NixOS Configuration with Flakes and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-ld.url = "github:Mic92/nix-ld";

    # Home Manager input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Blacklist for hosts
    ultimate-hosts-blacklist = {
      url = "github:Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist";
      flake = false; # Not a flake, so mark as false
    };

    # Ensure nix-ld uses the same nixpkgs version
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ultimate-hosts-blacklist, nix-ld, ... }:
    let
      system = "x86_64-linux";

      # This is the standard package set that modules can override.
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      # A second, completely independent package set that will NOT be
      # affected by any module overrides.
      pristinePkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

    in
    {
      nixosConfigurations.Framework = nixpkgs.lib.nixosSystem {
        inherit system;

        # Pass the clean package set into all modules.
        specialArgs = {
          inherit pristinePkgs;
        };

        modules = [
          ./configuration.nix
        ];
      };
    };
}
