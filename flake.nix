{
  description = "NixOS Configuration with Flakes and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # nix-ld for running dynamically linked binaries
    nix-ld.url = "github:Mic92/nix-ld";
    nix-ld.inputs.nixpkgs.follows = "nixpkgs"; # Ensures nixpkgs consistency

    # Home Manager input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Blacklist etc
    ultimate-hosts-blacklist = {
      url = "github:Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist";
      flake = false; # This is not a flake, so we set `flake = false`
    };
  };

  outputs = { self, nixpkgs, nix-ld, home-manager, ultimate-hosts-blacklist, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.Framework = nixpkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager

          # nix-ld module for dynamic library support
          nix-ld.nixosModules.nix-ld

          # Enable nix-ld development module
          { programs.nix-ld.dev.enable = true; }

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

