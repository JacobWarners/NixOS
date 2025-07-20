# /path/to/your/apps/ratatat-rust/flake.nix
{
  description = "A NixOS daemon to listen for the 'ratatat' key sequence.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  # The '...' here tells Nix to ignore any extra arguments passed to this function.
  outputs = { self, nixpkgs, ... }:
    let
      # We define the system once here.
      system = "x86_64-linux";
      # Create a pkgs set for our system.
      pkgs = import nixpkgs { inherit system; };
    in
    {
      # Define the NixOS module directly. This is the path your main flake is looking for.
      nixosModules.default = { config, lib, ... }: {
        options.services.ratatat-listener.enable = lib.mkEnableOption "Enable the ratatat listener daemon";

        config = lib.mkIf config.services.ratatat-listener.enable {
          # Install the final package (defined below) and mpg123.
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
              ExecStart = "${self.packages.${system}.default}/bin/ratatat-listener";
              Restart = "always";
              RestartSec = "5s";
            };
          };
        };
      };

      # Define the package for our specific system.
      packages.x86_64-linux.default = pkgs.rustPlatform.buildRustPackage rec {
        pname = "ratatat-listener";
        version = "0.1.0";
        src = self;

        cargoLock = {
          lockFile = ./Cargo.lock;
        };

        # Tools needed at build time.
        nativeBuildInputs = [
          pkgs.pkg-config
        ];

        # Libraries to link against.
        buildInputs = [
          pkgs.udev
          pkgs.xorg.xlibsWrapper
        ];
      };

      # Define the devShell for `nix develop`.
      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = [
          pkgs.rustc
          pkgs.cargo
          pkgs.pkg-config
          pkgs.udev
          pkgs.xorg.xlibsWrapper
        ];
      };
    };
}

