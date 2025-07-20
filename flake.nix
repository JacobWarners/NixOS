# /home/jake/nixos-config/flake.nix
{
  description = "NixOS Configuration with Flakes and Home Manager";

  inputs = {
    # NixOS official packages for the 25.05 stable release.
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-25.05";

    # Home Manager input, following the same nixpkgs version.
    home-manager = {
      url = "github:nix-community/home-manager/release-25.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Blacklist for hosts (this is correctly configured).
    ultimate-hosts-blacklist = {
      url = "github:Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist";
      flake = false;
    };

    # Point to the ratatat-listener project on your filesystem.
    ratatat-listener = {
      url = "path:./apps/ratatat-rust";
      flake = true;
    };
  };

  # Make sure to add 'ratatat-listener' to the function arguments here
  outputs = { self, nixpkgs, home-manager, ultimate-hosts-blacklist, ratatat-listener, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.Framework = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        modules = [
          # ... your other modules like nix-ld ...
          ({ pkgs, ... }: {
            programs.nix-ld.enable = true;
            programs.nix-ld.libraries = [ ];
          })

          # Import your other configurations
          ./configuration.nix

          # Home Manager module setup
          home-manager.nixosModules.home-manager,
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # This line is crucial. It passes your flake inputs (like ratatat-listener)
            # down to your Home Manager configuration.
            home-manager.extraSpecialArgs = { inherit inputs; };
            home-manager.users.jake = {
              # The imports go here, inside your user definition.
              # This is the line that fixes the error.
              imports = [
                ./home/home.nix
                inputs.ratatat-listener.homeManagerModules.default
              ];
            };
            home-manager.backupFileExtension = "backup";
          }

          # Host blacklist configuration
          ({ pkgs, ... }: {
            environment.etc."hosts.deny".source = pkgs.lib.mkForce
              "${ultimate-hosts-blacklist}/hosts.deny/hosts0.deny";
          })
        ];
      };
    };
}

