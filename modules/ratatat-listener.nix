{ config, pkgs, lib, ... }:

let
  user = "jake"; # Define your user here
  projectDir = "/home/${user}/Documents/Code/Rust/ratatat-rust";
  binaryPath = "${projectDir}/target/release/ratatat-rust";
in
{
  config = lib.mkIf config.services.ratatat-listener.enable {
    
    # 1. Allow 'jake' to read keyboard events (replacing root requirement)
    users.users.${user}.extraGroups = [ "input" ];

    systemd.services.ratatat-listener = {
      description = "Ratatat Keyboard Listener";
      wantedBy = [ "multi-user.target" ];
      
      path = with pkgs; [ 
        mpg123      
        procps      
        pulseaudio # Provides commands, but 'jake' uses the socket
      ];

      serviceConfig = {
        ExecStart = binaryPath;
        
        # 2. Run as YOU, not root.
        # This fixes the "Jack server/Connection refused" audio errors.
        User = user;
        
        # We set this, but the absolute path in Rust makes it redundant (good safety).
        WorkingDirectory = projectDir;

        Restart = "always";
        RestartSec = "5s";
      };
    };
  };
}
