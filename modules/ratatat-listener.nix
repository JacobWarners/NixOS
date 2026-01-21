{ config, lib, pkgs, ... }:

let
  # Your project folder
  projectRoot = "/home/jake/Documents/Code/Rust/ratatat-rust";
  # Relative path to binary inside that folder
  binaryRelativePath = "./target/release/ratatat-rust";
in
{
  systemd.user.services.ratatat-listener = {
    description = "Ratatat Listener Service (Nix-Shell Wrapper)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      # === THE FIX ===
      # Instead of running the binary directly, we spawn a nix-shell.
      # This guarantees the environment matches your successful manual test 100%.
      ExecStart = ''
        ${pkgs.nix}/bin/nix-shell -p alsa-lib openssl pulseaudio glibc --run "
          export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH
          # Use the dynamic loader to run the binary
          ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 ${binaryRelativePath}
        "
      '';

      # Run inside the folder so it finds 'Loud-pipes.mp3'
      WorkingDirectory = projectRoot;
      
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
