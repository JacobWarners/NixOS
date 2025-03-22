{
  description = "NixOS Configuration with Flakes and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    nix-ld.url = "github:Mic92/nix-ld";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ultimate-hosts-blacklist = {
      url = "github:Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist";
      flake = false;
    };
    nix-ld.inputs.nixpkgs.follows = "nixpkgs";
  };

  outputs = { self, nixpkgs, home-manager, ultimate-hosts-blacklist, nix-ld, ... }:
    let
      system = "x86_64-linux";
      # Define pkgs with the overlay
      pkgs = import nixpkgs {
        inherit system;
        overlays = [
          (final: prev: {
            etcd = prev.etcd.overrideAttrs (oldAttrs: {
              doCheck = false;
              checkPhase = "echo 'Tests skipped for etcd'";
            });
          })
        ];
      };
    in
    {
      nixosConfigurations.Framework = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit nix-ld; };
        modules = [
          # Ensure the system uses the overlaid pkgs
          {
            nixpkgs.pkgs = pkgs;
          }
          ./configuration.nix
          ./modules/nix-ld.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jake = import ./home/home.nix;
            home-manager.backupFileExtension = "backup";
          }
          {
            environment.etc."hosts.deny".source = pkgs.lib.mkForce
              "${ultimate-hosts-blacklist}/hosts.deny/hosts0.deny";
          }
        ];
      };
    };
}
