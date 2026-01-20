{ config, lib, pkgs, ... }:

let
  projectRoot = "/home/jake/Documents/Code/Rust/ratatat-rust";
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
  # CHANGE 1: Define inside 'systemd.user.services'
  systemd.user.services.ratatat-listener = {
    description = "Ratatat Listener Service (User Session)";
    
    # CHANGE 2: Start only after the graphical session (and audio) is ready
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    environment = {
      # We no longer need to manually hack DBUS/PULSE variables.
      # The user session provides them automatically.
      LD_LIBRARY_PATH = "${libraryPath}";
    };

    script = ''
      # We still need the loader trick for the binary
      LOADER="${pkgs.glibc}/lib/ld-linux-x86-64.so.2"
      exec $LOADER "${binaryPath}"
    '';

    serviceConfig = {
      # CHANGE 3: Remove 'User = jake'. 
      # User services automatically run as the logged-in user.
      WorkingDirectory = projectRoot;
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
