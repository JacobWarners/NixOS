# /path/to/your/apps/ratatat-rust/flake.nix

{
  description = "A NixOS daemon to listen for the 'ratatat' key sequence.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }:
    let
      pkgsFor = system: import nixpkgs { inherit system; };
    in
    {
      # This devShell is what `nix develop` uses.
      # It provides an environment with all the necessary build tools.
      devShells.x86_64-linux.default =
        let
          pkgs = pkgsFor "x86_64-linux";
        in
        pkgs.mkShell {
          buildInputs = [
            pkgs.rustc
            pkgs.cargo
            pkgs.pkg-config
            pkgs.wayland
            pkgs.libxkbcommon
          ];
        };

      # Define the NixOS module.
      nixosModules.default = { config, lib, pkgs, ... }:
        let
          system = pkgs.system;
          localPkgs = pkgsFor system;
          ratatat-pkg = localPkgs.rustPlatform.buildRustPackage rec {
            pname = "ratatat-listener";
            version = "0.1.0";
            src = self;

            cargoLock = {
              lockFile = ./Cargo.lock;
            };

            # With the Cargo.toml change, we only need Wayland-related dependencies.
            nativeBuildInputs = [
              localPkgs.pkg-config
              localPkgs.wayland
              localPkgs.libxkbcommon
            ];
          };
        in
        {
          options.services.ratatat-listener.enable = lib.mkEnableOption "Enable the ratatat listener daemon";

          config = lib.mkIf config.services.ratatat-listener.enable {
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
