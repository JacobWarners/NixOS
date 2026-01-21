{ config, lib, pkgs, ... }:

let
  projectRoot = "/home/jake/Documents/Code/Rust/ratatat-rust";
  binaryPath = "${projectRoot}/target/release/ratatat-rust";

  # 1. DEFINE LIBRARIES (So the binary can find them)
  libPath = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.openssl
    pkgs.alsa-lib
    pkgs.glibc
    pkgs.pulseaudio
  ];
  
  # 2. DEFINE ALSA PLUGINS (Critical for Rust audio on NixOS)
  alsaPluginDir = "${pkgs.alsa-plugins}/lib/alsa-lib";

  # 3. THE DIAGNOSTIC RUNNER
  # This script prints the environment checks to the log, then runs the app.
  debugRunner = pkgs.writeShellScript "ratatat-debug" ''
    echo "========== RATATAT DIAGNOSTICS =========="
    echo "1. WORKING DIR: $(pwd)"
    
    echo "2. CHECKING FILE:"
    if [ -f "Loud-pipes.mp3" ]; then
      echo "   [OK] Loud-pipes.mp3 found."
    else
      echo "   [ERROR] Loud-pipes.mp3 NOT FOUND!"
    fi

    # Set up the environment for the binary
    export LD_LIBRARY_PATH="${libPath}:$LD_LIBRARY_PATH"
    export ALSA_PLUGIN_DIRS="${alsaPluginDir}"
    
    echo "3. AUDIO ENVIRONMENT:"
    echo "   ALSA_PLUGIN_DIRS: $ALSA_PLUGIN_DIRS"
    echo "   PULSE_SERVER: $PULSE_SERVER"
    
    echo "4. STARTING BINARY..."
    # We use the loader trick because the binary is unpatched
    exec ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 "${binaryPath}"
  '';

in
{
  systemd.user.services.ratatat-listener = {
    description = "Ratatat Listener (Diagnostic)";
    
    # Match sonic-waygame dependencies
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" "pipewire.service" ];
    wants = [ "pipewire.service" ];

    serviceConfig = {
      # Match sonic-waygame delay to let audio initialize
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      
      # Point to our diagnostic script
      ExecStart = "${debugRunner}";
      
      WorkingDirectory = projectRoot;
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
