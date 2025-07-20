# /path/to/your/apps/ratatat-rust/flake.nix

{
  description = "A NixOS daemon to listen for the 'ratatat' key sequence.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
  };

  # The '...' here tells Nix to ignore any extra arguments passed to this function.
  # This makes the flake more robust and composable.
  outputs = { self, nixpkgs, ... }: {
    # This is now a top-level attribute, which your main flake can find.
    nixosModules.default = { config, lib, pkgs, ... }:
      let
        # We define the package right here inside the module.
        # This is a clean pattern that avoids flake-utils and recursion issues.
        ratatat-pkg = pkgs.rustPlatform.buildRustPackage rec {
          pname = "ratatat-listener";
          version = "0.1.0";

          # The source code is the flake directory itself.
          src = self;

          cargoLock = {
            lockFile = ./Cargo.lock;
          };

          # Dependencies needed during the build process.
          nativeBuildInputs = with pkgs; [
            pkg-config
            xorg.libX11
            xorg.libXtst
            xorg.libXi
            xorg.xorgproto # <-- This was corrected from 'xproto'
            xorg.xtstproto
            xorg.xineramaproto
            xorg.inputproto
            xorg.libxkbcommon
          ];
        };
      in
      {
        # The option that you use in configuration.nix
        options.services.ratatat-listener.enable = lib.mkEnableOption "Enable the ratatat listener daemon";

        # The configuration that is applied when the service is enabled.
        config = lib.mkIf config.services.ratatat-listener.enable {
          # Add the necessary packages to the system environment.
          environment.systemPackages = with pkgs; [
            ratatat-pkg
            mpg123
          ];

          # Define the systemd service.
          systemd.services.ratatat-listener = {
            description = "Listens for the 'ratatat' key sequence and plays a song.";
            after = [ "graphical-session.target" ];
            wants = [ "graphical-session.target" ];
            partOf = [ "graphical-session.target" ];
            serviceConfig = {
              # IMPORTANT: This user MUST be in the 'libinput' group.
              # Ensure `users.users.jake.extraGroups = [ "libinput" ];`
              # is in your main configuration.nix
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

