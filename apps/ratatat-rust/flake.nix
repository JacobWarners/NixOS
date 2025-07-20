# /path/to/your/apps/ratatat-rust/flake.nix
{
  description = "A NixOS daemon to listen for the 'ratatat' key sequence.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  outputs = { self, nixpkgs, ... }: {
    # Define the NixOS module. This is the only output your system needs.
    nixosModules.default = { config, lib, pkgs, ... }:
      let
        # DEFINE THE PACKAGE LOCALLY:
        # By defining the package inside a `let` block, its path is
        # guaranteed to be available to the service configuration below.
        ratatat-pkg = pkgs.rustPlatform.buildRustPackage rec {
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
          buildInputs = with pkgs.xorg; [
            pkgs.udev
            pkgs.libinput
            libX11
            libXtst
            libXi
            xorgproto
          ];
        };
      in
      {
        # The option you use in configuration.nix
        options.services.ratatat-listener.enable = lib.mkEnableOption "Enable the ratatat listener daemon";

        # The configuration that is applied when the service is enabled.
        config = lib.mkIf config.services.ratatat-listener.enable {
          # Install the final package and its runtime dependency (mpg123).
          environment.systemPackages = [
            ratatat-pkg
            pkgs.mpg123
          ];

          # Define the systemd service.
          systemd.services.ratatat-listener = {
            description = "Listens for the 'ratatat' key sequence and plays a song.";
            after = [ "graphical-session.target" ];
            wants = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            serviceConfig = {
              User = "jake";
              # USE THE LOCAL PACKAGE:
              # The ExecStart now points to the locally defined package.
              ExecStart = "${ratatat-pkg}/bin/ratatat-listener";
              Restart = "always";
              RestartSec = "5s";
            };
          };
        };
      };
  };
}

