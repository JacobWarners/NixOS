{ config, lib, pkgs, ... }:

let
  user = "jake";
  # PASS AS A STRING
  binaryPath = "/home/jake/Documents/Code/Rust/ratatat-rust/target/release/ratatat-listener";
in
{
  systemd.services.ratatat-listener = {
    description = "Ratatat Listener Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    # We use a script to ensure the binary is patched before running
    # This keeps your source folder clean but makes it work on NixOS
    script = ''
      # 1. Define where the dynamic loader is on YOUR system
      LOADER="${pkgs.glibc}/lib/ld-linux-x86-64.so.2"
      
      # 2. Run the binary using the loader explicitly
      # This forces the binary to use the NixOS loader, ignoring what it was built with.
      exec $LOADER "${binaryPath}"
    '';

    serviceConfig = {
      User = user;
      Group = "users";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
