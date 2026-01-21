{ config, lib, pkgs, ... }:

let
  # 1. PATHS
  projectRoot = "/home/jake/Documents/Code/Rust/ratatat-rust";
  binaryPath = "${projectRoot}/target/release/ratatat-rust";

  # 2. LIBRARIES & PLUGINS (The stuff Nix used to do for you)
  # We explicitly grab the ALSA plugins so audio works.
  alsaPluginDir = "${pkgs.alsa-plugins}/lib/alsa-lib";
  
  libPath = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.openssl
    pkgs.alsa-lib
    pkgs.glibc
    pkgs.pulseaudio
  ];

  # 3. THE WRAPPER SCRIPT
  # We create a script in the Nix store that sets up the environment 
  # and THEN runs your binary. This is what 'ExecStart' will point to.
  runnerScript = pkgs.writeShellScript "ratatat-runner" ''
    # Set the library path so the binary finds .so files
    export LD_LIBRARY_PATH="${libPath}:$LD_LIBRARY_PATH"
    
    # Set the ALSA plugin directory (CRITICAL for audio on NixOS)
    export ALSA_PLUGIN_DIRS="${alsaPluginDir}"
    
    # Force PulseAudio backend just in case
    export ALSA_OUTPUT_DRIVER=pulse
    
    # Run the binary using the dynamic loader
    exec ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 "${binaryPath}"
  '';

in
{
  systemd.user.services.ratatat-listener = {
    description = "Ratatat Listener Service (Wrapper)";
    
    # Start after graphical session is up
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      # Point Systemd to our clean wrapper script
      ExecStart = "${runnerScript}";
      
      # Run inside the project root so it finds 'Loud-pipes.mp3'
      WorkingDirectory = projectRoot;
      
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
