{ config, lib, pkgs, ... }:

let
  user = "jake";
  # Double check this path matches your file location exactly
  binaryPath = "/home/jake/Documents/Code/Rust/ratatat-rust/target/release/ratatat-rust";

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

    # === 1. ENVIRONMENT VARIABLES (Correct Way) ===
    # We define them here as a set, instead of inside serviceConfig
    environment = {
      # Point to your user's runtime directory (usually /run/user/1000 for the first user)
      XDG_RUNTIME_DIR = "/run/user/1000";
      # Helper for Pipewire/PulseAudio
      PULSE_SERVER = "unix:/run/user/1000/pulse/native";
      # Ensure the library path is set here too
      LD_LIBRARY_PATH = "${libraryPath}";
    };

    # === 2. THE SCRIPT ===
    script = ''
      # We still use the loader trick
      LOADER="${pkgs.glibc}/lib/ld-linux-x86-64.so.2"
      
      # Execute the binary
      exec $LOADER "${binaryPath}"
    '';

    # === 3. SERVICE CONFIG ===
    serviceConfig = {
      User = user;
      Group = "users";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
