{ config, lib, pkgs, ... }:

let
  # 1. DEFINE PATHS
  projectRoot = "/home/jake/Documents/Code/Rust/ratatat-rust";
  binaryPath = "${projectRoot}/target/release/ratatat-rust";

  # 2. SETUP LIBRARIES (Matches your working manual test)
  libPath = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.openssl
    pkgs.alsa-lib
    pkgs.glibc
    pkgs.pulseaudio
  ];

  # 3. DIAGNOSTIC SCRIPT
  # This script runs diagnostics first, THEN runs the app.
  # We use 'writeShellScript' to avoid syntax errors in the unit file.
  debugRunner = pkgs.writeShellScript "ratatat-debug" ''
    echo "========== RATATAT DIAGNOSTICS START =========="
    
    echo "--- 1. WHERE AM I? ---"
    echo "Current Directory: $(pwd)"
    
    echo "--- 2. CAN I SEE THE FILE? ---"
    ls -l Loud-pipes.mp3 || echo "CRITICAL ERROR: Loud-pipes.mp3 NOT FOUND in $(pwd)"
    
    echo "--- 3. IS THE BINARY LINKED? ---"
    # We check if the binary can find its libraries inside this service
    export LD_LIBRARY_PATH="${libPath}:$LD_LIBRARY_PATH"
    ${pkgs.glibc}/bin/ldd "${binaryPath}" | grep "not found" && echo "CRITICAL ERROR: MISSING LIBRARIES" || echo "Libraries look good."

    echo "--- 4. AUDIO ENVIRONMENT ---"
    echo "XDG_RUNTIME_DIR: $XDG_RUNTIME_DIR"
    echo "PULSE_SERVER: $PULSE_SERVER"
    echo "ALSA_PLUGIN_DIRS: $ALSA_PLUGIN_DIRS"
    
    echo "--- 5. LAUNCHING APP ---"
    # Use the loader to run the binary (same as your manual test)
    exec ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 "${binaryPath}"
  '';

in
{
  systemd.user.services.ratatat-listener = {
    description = "Ratatat Listener (Diagnostic Mode)";
    
    # Wait for audio, just like sonic-waygame
    wantedBy = [ "default.target" ];
    after = [ "graphical-session.target" "pipewire.service" ];
    wants = [ "pipewire.service" ];

    serviceConfig = {
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      
      # Run our debug script
      ExecStart = "${debugRunner}";
      
      WorkingDirectory = projectRoot;
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
