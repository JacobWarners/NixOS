# /path/to/your/apps/ratatat-rust/flake.nix

{
  description = "A NixOS daemon to listen for the 'ratatat' key sequence.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      # Define a package set using this flake's own nixpkgs input.
      # This ensures the build is isolated from the host system's nixpkgs version.
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      # Define the NixOS module.
      # 'system' is removed from the arguments here, as it's not passed automatically.
      nixosModules.default = { config, lib, pkgs, ... }:
        let
          # We derive the system from the 'pkgs' argument, which is always available.
          system = pkgs.system;
          # Use the isolated package set to build the Rust application.
          localPkgs = pkgsFor system;
          ratatat-pkg = localPkgs.rustPlatform.buildRustPackage rec {
            pname = "ratatat-listener";
            version = "0.1.0";
            src = self;

            cargoLock = {
              lockFile = ./Cargo.lock;
            };

            # Use the isolated 'localPkgs' for all build dependencies.
            nativeBuildInputs = [
              localPkgs.pkg-config
              localPkgs.xorg.xlibsWrapper
              localPkgs.libxkbcommon
            ];
          };
        in
        {
          options.services.ratatat-listener.enable = lib.mkEnableOption "Enable the ratatat listener daemon";

          config = lib.mkIf config.services.ratatat-listener.enable {
            # Install the final package and its runtime dependency (mpg123)
            # into the main system environment.
            environment.systemPackages = [
              ratatat-pkg
              pkgs.mpg123
            ];

            systemd.services.ratatat-listener = {
              description = "Listens for the 'ratatat' key sequence and plays a song.";
              after = [ "graphical-session.target" ];
              wants = [ "graphical-session.target" ];
              partOf = [ "graphical-session.target" ];
              serviceConfig = {
                User = "jake";
                ExecStart = "${ratatat-pkg}/bin/ratatat-listener";
                Restart = "always";
                RestartSec = "5s";
              };
            };
          };
        };
    };
}

