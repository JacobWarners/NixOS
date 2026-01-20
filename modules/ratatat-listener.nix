{ config, pkgs, lib, ... }:

let
  user = "jake";
  projectDir = "/home/${user}/Documents/Code/Rust/ratatat-rust";
  binaryPath = "${projectDir}/target/release/ratatat-rust";
in
{
  # --- FIX STARTS HERE ---
  # We must explicitly tell NixOS that this service option exists.
  options.services.ratatat-listener = {
    enable = lib.mkEnableOption "Ratatat Keyboard Listener";
  };
  # --- FIX ENDS HERE ---

  config = lib.mkIf config.services.ratatat-listener.enable {
    
    # 1. Permission for 'jake' to read /dev/input
    users.users.${user}.extraGroups = [ "input" ];

    systemd.services.ratatat-listener = {
      description = "Ratatat Keyboard Listener";
      wantedBy = [ "multi-user.target" ];
      
      path = with pkgs; [ 
        mpg123      
        procps      
        pulseaudio 
      ];

      serviceConfig = {
        ExecStart = binaryPath;
        User = user;
        WorkingDirectory = projectDir;
        Restart = "always";
        RestartSec = "5s";

        # 2. Audio Environment Variables (So the service finds your speakers)
        Environment = [
          "XDG_RUNTIME_DIR=/run/user/1000"
          "PULSE_SERVER=unix:/run/user/1000/pulse/native"
        ];
      };
    };
  };
}
