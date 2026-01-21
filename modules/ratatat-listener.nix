{ config, pkgs, lib, ... }:

let
  projectRoot = "/home/jake/Documents/Code/Rust/ratatat-rust";
  # We still need the libraries defined, just in case
  libPath = lib.makeLibraryPath [
    pkgs.stdenv.cc.cc.lib
    pkgs.openssl
    pkgs.alsa-lib
    pkgs.glibc
    pkgs.pulseaudio
  ];
in
{
  systemd.user.services.ratatat-listener = {
    description = "Ratatat Listener Service";
    
    # 1. MATCHING SONIC: Start with the user session default target
    wantedBy = [ "default.target" ];

    # 2. MATCHING SONIC: Wait specifically for PipeWire
    after = [ "graphical-session.target" "pipewire.service" ];
    wants = [ "pipewire.service" ];

    serviceConfig = {
      # 3. MATCHING SONIC: The critical delay to prevent silent start
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";
      
      # 4. Working Directory (Critical for ratatat to find the MP3)
      WorkingDirectory = projectRoot;

      Restart = "always";
      RestartSec = "1s";
    };

    # 5. THE RUNNER
    # We use 'script' instead of 'ExecStart' ONLY because your binary is unpatched.
    # It does the exact same thing as ExecStart but helps it find the libraries.
    script = ''
      export LD_LIBRARY_PATH="${libPath}:$LD_LIBRARY_PATH"
      
      # Force the binary to use the system loader (standard for unpatched binaries on NixOS)
      exec ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 "${projectRoot}/target/release/ratatat-rust"
    '';
  };
}
