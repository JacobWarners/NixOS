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
    
    path = [ pkgs.ffmpeg pkgs.unixtools.nice ];

    serviceConfig = {
      ExecStart = "/home/jake/Documents/Code/Rust/obs-transcriber/target/release/video-transcriber";

      # 2. CHANGE HERE: Use 'Environment' instead of 'EnvironmentFile'
      # We inject the string directly from the imported secrets set.
      Environment = "GEMINI_API_KEY=${secrets.GEMINI_API_KEY}";

      Restart = "on-failure";
      RestartSec = "10s";
      CPUWeight = 20;
      IOWeight = 20;
    };
  };
}
