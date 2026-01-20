{ config, lib, pkgs, ... }:

let
  user = "jake";
  # UPDATED: Correct filename 'ratatat-rust'
  binaryPath = "/home/jake/Documents/Code/Rust/ratatat-rust/target/release/ratatat-rust";

  # Standard libraries for Rust binaries on NixOS
  libraryPath = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.openssl
    pkgs.alsa-lib
    pkgs.glibc
  ];
in
{
  systemd.services.ratatat-listener = {
    description = "Ratatat Listener Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    script = ''
      export LD_LIBRARY_PATH=${libraryPath}:$LD_LIBRARY_PATH
      LOADER="${pkgs.glibc}/lib/ld-linux-x86-64.so.2"
      
      # Execute the binary using the NixOS loader
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
