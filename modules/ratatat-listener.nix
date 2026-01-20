{ config, lib, pkgs, ... }:

let
  # 1. Let Nix build the package from your source code
  # This fixes the "203/EXEC" error by linking it correctly for NixOS.
  ratatatPkg = pkgs.rustPlatform.buildRustPackage {
    pname = "ratatat-listener";
    version = "0.1.0";

    # Point this to your actual source code
    # NOTE: If using Flakes, you may need to run 'git add' on this folder 
    # or run rebuild with '--impure'.
    src = /home/jake/Documents/Code/Rust/ratatat-rust;

    # Nix needs the Cargo.lock to know exactly what dependencies to fetch
    cargoLock = {
      lockFile = /home/jake/Documents/Code/Rust/ratatat-rust/Cargo.lock;
    };
  };
in
{
  # Run the service directly
  systemd.services.ratatat-listener = {
    description = "Ratatat Listener Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      # Runs the binary built above. 
      # I removed '--port 8080'. If your code NEEDS arguments, add them back here.
      ExecStart = "${ratatatPkg}/bin/ratatat-listener";
      
      # Run as your user so it has access to your files/environment
      User = "jake";
      Group = "users";
      
      # Restart if it crashes
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
