# /path/to/your/apps/ratatat-rust/flake.nix
{
  description = "A NixOS daemon to listen for the 'ratatat' key sequence.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs { inherit system; };
      in
      {
        # Define the package at the top level. This is a robust pattern.
        packages.default = pkgs.rustPlatform.buildRustPackage rec {
          pname = "ratatat-listener";
          version = "0.1.0";
          src = self;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          # Provide all necessary dependencies for inputbot, including X11.
          nativeBuildInputs = [
            pkgs.pkg-config
            pkgs.udev
            pkgs.xorg.xlibsWrapper
          ];
        };

        # Define the NixOS module that will use the package.
        nixosModules.default = { config, lib, ... }: {
          options.services.ratatat-listener.enable = lib.mkEnableOption "Enable the ratatat listener daemon";

          config = lib.mkIf config.services.ratatat-listener.enable {
            # Install the final package (built above) and mpg123.
            environment.systemPackages = [
              self.packages.${system}.default
              pkgs.mpg123
            ];

            systemd.services.ratatat-listener = {
              description = "Listens for the 'ratatat' key sequence and plays a song.";
              after = [ "graphical-session.target" ];
              wants = [ "graphical-session.target" ];
              partOf = [ "graphical-session.target" ];
              serviceConfig = {
                User = "jake";
                # The ExecStart now points to the top-level package.
                ExecStart = "${self.packages.${system}.default}/bin/ratatat-listener";
                Restart = "always";
                RestartSec = "5s";
              };
            };
          };
        };

        # Define the devShell for `nix develop`.
        devShells.default = pkgs.mkShell {
          buildInputs = [
            pkgs.rustc
            pkgs.cargo
            pkgs.pkg-config
            pkgs.udev
            pkgs.xorg.xlibsWrapper
          ];
        };
      }
    );
}

