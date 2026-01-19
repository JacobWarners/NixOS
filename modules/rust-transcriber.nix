{ config, pkgs, ... }:

let
  # 1. Explicitly import the secrets file from the parent directory
  secrets = import ../secrets.nix;
in
{
  systemd.user.services.obs-transcriber = {
    description = "Rust OBS Video Transcriber";
    after = [ "network-online.target" ];
    wantedBy = [ "graphical-session.target" ];
    
    # FIX: 'nice' is in coreutils, not unixtools. 
    path = [ pkgs.ffmpeg pkgs.coreutils ];

    serviceConfig = {
      # Make sure you ran 'cargo build --release' for this path to exist!
      ExecStart = "/home/jake/Documents/Code/Rust/obs-transcriber/target/release/video-transcriber";

      # 2. Secret Injection
      Environment = "GEMINI_API_KEY=${secrets.GEMINI_API_KEY}";

      Restart = "on-failure";
      RestartSec = "10s";

      # Resource Constraints
      CPUWeight = 20;
      IOWeight = 20;
      
      # FIX: The Systemd-native way to run as low priority (19 is lowest priority)
      Nice = 19; 
    };
  };
}
