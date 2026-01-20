{ config, lib, pkgs, ... }:

let
  user = "jake";
  # Ensure this points to the ROOT folder where 'Loud-pipes.mp3' is
  projectRoot = "/home/jake/Documents/Code/Rust/ratatat-rust";
  
  # Ensure this points to the compiled binary
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
      # 1. Runtime Directory
      XDG_RUNTIME_DIR = "/run/user/1000";
      
      # 2. PulseAudio Socket
      PULSE_SERVER = "unix:/run/user/1000/pulse/native";
      
      # 3. === THE MISSING LINK: DBus Bus ===
      # This allows the app to negotiate audio permissions with the desktop
      DBUS_SESSION_BUS_ADDRESS = "unix:path=/run/user/1000/bus";
      
      # 4. Libraries
      LD_LIBRARY_PATH = "${libraryPath}";
    };

    script = ''
      LOADER="${pkgs.glibc}/lib/ld-linux-x86-64.so.2"
      exec $LOADER "${binaryPath}"
    '';

    serviceConfig = {
      User = user;
      Group = "users";
      WorkingDirectory = projectRoot; # Must be here to find the MP3
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
