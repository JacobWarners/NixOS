{ config, lib, pkgs, ... }:

let
  user = "jake";
  # PASS AS A STRING: Nix won't check if this exists during build
  binaryPath = "/home/jake/Documents/Code/Rust/ratatat-rust/target/release/ratatat-listener";
in
{
  systemd.services.ratatat-listener = {
    description = "Ratatat Listener Service";
    after = [ "network.target" ];
    wantedBy = [ "multi-user.target" ];

    serviceConfig = {
      # We still use the loader trick to run the non-Nix binary
      ExecStart = "${pkgs.glibc}/lib/ld-linux-x86-64.so.2 ${binaryPath}";
      
      # We need to give it the libraries it expects (libc, etc)
      Environment = "LD_LIBRARY_PATH=${lib.makeLibraryPath [ pkgs.stdenv.cc.cc pkgs.glibc ]}";

      User = user;
      Group = "users";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
