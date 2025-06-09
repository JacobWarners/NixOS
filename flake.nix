2 {
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
      # This is what most of your system will use.
      pkgs = import nixpkgs {
        inherit system;
        # Add any global overlays or configs for the main pkgs here
        config.allowUnfree = true;
      };

      # ==> THIS IS THE CRITICAL ADDITION <==
      # This is a second, completely independent package set.
      # It will not be affected by any module overrides.
      pristinePkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true; # Also needs to know about unfree setting
      };

    in
    {
      nixosConfigurations.Framework = nixpkgs.lib.nixosSystem {
        inherit system;

        # ==> PASS THE CLEAN SET INTO ALL MODULES <==
        # It will be available as an argument to every module.
        specialArgs = {
          inherit pristinePkgs;
        };

        modules = [
          ./configuration.nix
          # Your other modules are imported inside configuration.nix
        ];
      };
    };
}
