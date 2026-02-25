{
  description = "NixOS Configuration with Flakes and Home Manager";

  inputs = {
    nix-snapd.url = "github:nix-community/nix-snapd";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.11";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ultimate-hosts-blacklist = {
      url = "github:Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist";
      flake = false;
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { self, nixpkgs, home-manager, ultimate-hosts-blacklist, sops-nix, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system};
      # Create a dedicated package set for the i686 (32-bit) architecture.
      pkgs-i686 = nixpkgs.legacyPackages."i686-linux";
    in
    {
      nixosConfigurations.Framework = nixpkgs.lib.nixosSystem {
        inherit system;
        # Pass the 32-bit package set down to all modules via specialArgs.
        specialArgs = { inherit inputs pkgs-i686; };

        modules = [
          ./configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          inputs.nix-snapd.nixosModules.default

          ({ pkgs, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.jake = {
              imports = [
                ./home/home.nix
              ];
            };
            home-manager.backupFileExtension = "backup";
          })
        ];
      };
      homeConfigurations.jake = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; };
        modules = [
          ./home/home.nix
        ];
      };
    };
}
