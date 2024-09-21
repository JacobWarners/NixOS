{
  description = "NixOS Configuration with Flakes and Home Manager";

  inputs = {
    # Nixpkgs input
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    
    # Hyprland input
    hyprland.url = "github:hyprwm/Hyprland";

    # Home Manager input
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Ultimate Hosts Blacklist input
    ultimate-hosts-blacklist = {
      url = "github:Ultimate-Hosts-Blacklist/Ultimate.Hosts.Blacklist";
      flake = false;  # This is not a flake, so we set `flake = false`
    };
  };

  outputs = { self, nixpkgs, home-manager, ultimate-hosts-blacklist, ... }:
    let
      system = "x86_64-linux";
      pkgs = import nixpkgs { inherit system; };
    in
    {
      nixosConfigurations.Framework = pkgs.lib.nixosSystem {
        inherit system;
        modules = [
          ./configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.jake = import ./home/home.nix;
            home-manager.backupFileExtension = "backup";
          }

          # Integrating Ultimate Hosts Blacklist's `hosts0.deny` as `hosts.deny`
          {
            environment.etc."hosts.deny".source = pkgs.lib.mkForce
              "${ultimate-hosts-blacklist}/hosts.deny/hosts0.deny";
          }
        ];
      };
    };
}

