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

    # Hyprland input. Note: Pointing to the main branch may cause cache misses.
    # It's better to use pkgs.hyprland unless you need the absolute latest version.
    hyprland.url = "github:hyprwm/Hyprland";
    hypr-dynamic-cursors = {
      url = "github:VirtCode/hypr-dynamic-cursors";
      inputs.hyprland.follows = "hyprland";
    };

    # Blacklist for hosts (this is correctly configured).
    ultimate-hosts-blacklist = {
      url = "github:Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist";
      flake = false;
    };
  };

  outputs = { self, nixpkgs, home-manager, hyprland, ultimate-hosts-blacklist, ... }@inputs:
    let
      system = "x86_64-linux";
    in
    {
      nixosConfigurations.Framework = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = { inherit inputs; };

        # 'specialArgs' can pass inputs to your modules. 'nix-ld' is removed from here.
        #         specialArgs = {
        #           # Pass your other inputs if needed in your custom modules.
        #           inherit hyprland ultimate-hosts-blacklist;
        #         };

        modules = [
          # This is the correct way to enable and configure nix-ld.
          # It uses the version from `nixpkgs`, ensuring cache hits.
          ({ pkgs, ... }: {
            programs.nix-ld.enable = true;
            programs.nix-ld.libraries = [
              # Add libraries that need nix-ld here, e.g.:
              # pkgs.zlib
            ];
          })

          # WARNING: You have two places configuring nix-ld.
          # The module above is sufficient. You should REMOVE the line below
          # to avoid conflicting configurations.
          # ./modules/nix-ld.nix # <-- REMOVE THIS LINE

          # Import your other configurations
          ./configuration.nix

          # Home Manager module setup
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jake = import ./home/home.nix;
            home-manager.backupFileExtension = "backup";

            # This allows home-manager configurations to access flake inputs
            home-manager.extraSpecialArgs = {
              inherit hyprland;
            };
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
