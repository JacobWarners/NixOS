# /home/jake/nixos-config/flake.nix
{
  description = "NixOS Configuration with Flakes and Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ultimate-hosts-blacklist = {
      url = "github:Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist";
      flake = false;
    };
    ratatat-listener = {
      url = "path:./apps/ratatat-rust";
      flake = true;
    };
  };

  outputs = { self, nixpkgs, home-manager, ultimate-hosts-blacklist, ratatat-listener, ... }@inputs:
    let
      system = "x86_64-linux";
      pkgs = nixpkgs.legacyPackages.${system}; # <-- ADD THIS LINE
    in
    {
      nixosConfigurations.Framework = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager

          # This wrapper makes your Home Manager settings a valid module.
          # This is the critical fix.
          ({ pkgs, ... }: {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.jake = {
              imports = [
                ./home/home.nix
                inputs.ratatat-listener.homeManagerModules.default
              ];
            };
            home-manager.backupFileExtension = "backup";
          })
        ];
      };
      homeConfigurations.jake = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = { inherit inputs; }; # Makes inputs available in home.nix
        modules = [
          ./home/home.nix
          inputs.ratatat-listener.homeManagerModules.default
        ];
      };
    };
}
