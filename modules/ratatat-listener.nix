{ config, lib, pkgs, ... }:

let
  user = "jake";
  
  # 1. ROOT folder (where Cargo.toml and Loud-pipes.mp3 are)
  projectRoot = "/home/jake/Documents/Code/Rust/ratatat-rust";
  
  # 2. BINARY path (where the executable lives)
  binaryPath = "${projectRoot}/target/release/ratatat-rust";

  libraryPath = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.openssl
    pkgs.alsa-lib
    pkgs.glibc
    pkgs.pulseaudio
  ];
in
{
  systemd.services.ratatat-listener = {
    description = "Ratatat Listener Service";
    after = [ "network.target" "sound.target" ];
    wantedBy = [ "multi-user.target" ];

    environment = {
      XDG_RUNTIME_DIR = "/run/user/1000";
      PULSE_SERVER = "unix:/run/user/1000/pulse/native";
      LD_LIBRARY_PATH = "${libraryPath}";
    };

    script = ''
      LOADER="${pkgs.glibc}/lib/ld-linux-x86-64.so.2"
      exec $LOADER "${binaryPath}"
    '';

    serviceConfig = {
      User = user;
      Group = "users";
      
      # === THE FIX: Run from the project root so it finds Loud-pipes.mp3 ===
      WorkingDirectory = projectRoot;
      
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
