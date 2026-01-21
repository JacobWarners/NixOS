{ config, lib, pkgs, ... }:

let
  projectRoot = "/home/jake/Documents/Code/Rust/ratatat-rust";
  # We point to the binary, but we will run it via nix-shell
  binaryPath = "target/release/ratatat-rust";
in
{
  systemd.user.services.ratatat-listener = {
    description = "Ratatat Listener Service (Nix-Shell Wrapper)";
    wantedBy = [ "graphical-session.target" ];
    partOf = [ "graphical-session.target" ];

    serviceConfig = {
      # 1. Run exactly like your manual test:
      #    - Enter nix-shell with audio libs
      #    - Export the library path (Critical!)
      #    - Run the binary using the loader trick
      ExecStart = ''
        ${pkgs.nix}/bin/nix-shell -p alsa-lib openssl pulseaudio glibc --run "
          export LD_LIBRARY_PATH=\$LD_LIBRARY_PATH
          ${pkgs.glibc}/lib/ld-linux-x86-64.so.2 ./${binaryPath}
        "
      '';

      # 2. Run inside the project root so it finds 'Loud-pipes.mp3'
      WorkingDirectory = projectRoot;
      
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
