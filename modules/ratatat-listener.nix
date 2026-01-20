{ config, lib, pkgs, ... }:

let
  projectRoot = "/home/jake/Documents/Code/Rust/ratatat-rust";
  binaryPath = "${projectRoot}/target/release/ratatat-rust";

  # 1. We need the plugins so ALSA apps can talk to Pulse/Pipewire
  alsaPlugins = pkgs.alsa-plugins;
  
  libraryPath = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.openssl
    pkgs.alsa-lib
    pkgs.glibc
    pkgs.pulseaudio
  ];
in
{
  systemd.user.services.ratatat-listener = {
    description = "Ratatat Listener Service (User Session)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    environment = {
      LD_LIBRARY_PATH = "${libraryPath}";
      
      # 2. FORCE the application to use the Pulse backend for ALSA
      ALSA_OUTPUT_DRIVER = "pulse";
      
      # 3. Tell it where the plugins are (Critical for NixOS)
      ALSA_PLUGIN_DIRS = "${alsaPlugins}/lib/alsa-lib";
    };

    script = ''
      LOADER="${pkgs.glibc}/lib/ld-linux-x86-64.so.2"
      exec $LOADER "${binaryPath}"
    '';

    serviceConfig = {
      WorkingDirectory = projectRoot;
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
