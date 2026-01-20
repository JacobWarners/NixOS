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
    pkgs.pulseaudio # Added Pulse just in case the app uses it
  ];
in
{
  systemd.services.ratatat-listener = {
    description = "Ratatat Listener Service";
    after = [ "network.target" "sound.target" ]; # Wait for sound system
    wantedBy = [ "multi-user.target" ];

    script = ''
      export LD_LIBRARY_PATH=${libraryPath}:$LD_LIBRARY_PATH
      LOADER="${pkgs.glibc}/lib/ld-linux-x86-64.so.2"
      exec $LOADER "${binaryPath}"
    '';

    serviceConfig = {
      User = user;
      Group = "users";
      Restart = "always";
      RestartSec = "5s";

      # === THE FIX: Connect to your Audio System ===
      # Background services don't know where Pipewire/Pulse lives by default.
      # We point it to your user's runtime directory (UID 1000 is standard for the first user).
      Environment = "XDG_RUNTIME_DIR=/run/user/1000";
      
      # If you use Pipewire/Pulse, this helps the app find the socket:
      Environment = "PULSE_SERVER=unix:/run/user/1000/pulse/native";
    };
  };
}
