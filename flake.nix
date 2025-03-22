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
      # Import nixpkgs with your overlay for etcd (used elsewhere in your configuration)
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            etcd = prev.etcd.overrideAttrs (oldAttrs: {
              doCheck = false;
            });
          })
        ];
      };
    in
    {
      # Instead of using the locally imported (and overlaid) value,
      # use nixpkgs.lib.nixosSystem to build your NixOS configuration.
      nixosConfigurations.Framework = nixpkgs.lib.nixosSystem {
        system = system;
        modules = [
          ./configuration.nix # Base configuration
          ./modules/nix-ld.nix # nix-ld module
          home-manager.nixosModules.home-manager # Home Manager module
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jake = import ./home/home.nix;
            home-manager.backupFileExtension = "backup";
          }
          {
            environment.etc."hosts.deny".source =
              nixpkgs.lib.mkForce "${ultimate-hosts-blacklist}/hosts.deny/hosts0.deny";
          }
        ];
      };
    };
}

