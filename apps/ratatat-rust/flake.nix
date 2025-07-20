# /path/to/your/conf/g/scripts/ratatat-rust/flake.nix

{
  description = "A NixOS daemon to listen for the 'ratatat' key sequence.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachDefaultSystem (system:
      let
        pkgs = import nixpkgs {
          inherit system;
        };
      in
      {
        # This package builds our Rust application.
        packages.ratatat-listener = pkgs.rustPlatform.buildRustPackage rec {
          pname = "ratatat-listener";
          version = "0.1.0";

          src = ./.; # Assumes your flake.nix is in the same directory as your Rust project

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          # Dependencies needed during the build process.
          # We've moved the xorg libraries here to ensure pkg-config can find them.
          nativeBuildInputs = with pkgs; [
            pkg-config
            xorg.libX11
            xorg.libXtst
            xorg.libXi
            xorg.xproto
            xorg.xtstproto
            xorg.xineramaproto
            xorg.inputproto
            xorg.libxkbcommon
          ];
        };

        # Default package for `nix build`
        defaultPackage = self.packages.${system}.ratatat-listener;

        # NixOS module to create the systemd service.
        nixosModules.default = { config, lib, ... }: {
          # Define a new NixOS option for enabling our service.
          options.services.ratatat-listener.enable = lib.mkEnableOption "Enable the ratatat listener daemon";

          config = lib.mkIf config.services.ratatat-listener.enable {
            # Add necessary packages to the system environment
            environment.systemPackages = with pkgs; [
              self.packages.${system}.ratatat-listener
              mpg123 # The command-line music player
            ];

            # Define the systemd service
            systemd.services.ratatat-listener = {
              description = "Listens for the 'ratatat' key sequence and plays a song.";
              
              # This service should run after the graphical session is available.
              after = [ "graphical-session.target" ];
              wants = [ "graphical-session.target" ];

              serviceConfig = {
                # The user the service will run as.
                # It's important to run it as your user to access the display server.
                User = "jake"; # <-- This is set to your username

                # The command to start the daemon.
                ExecStart = "${self.packages.${system}.ratatat-listener}/bin/ratatat-listener";
                
                # Automatically restart the service if it fails.
                Restart = "always";
                RestartSec = "5s";

                # Required to allow the program to connect to the display server.
                # This works for both Wayland and X11 sessions.
                EnvironmentFile = "/home/jake/.config/systemd/user/env";
              };
            };
          };
        };
      }
    );
}

