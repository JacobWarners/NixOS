# ./modules/transcriber.nix

{ config, pkgs, ... }:

{
  # This line is the start of the configuration set
  
  systemd.services.auto-transcriber = {
    description = "Watches the OBS folder and transcribes new videos";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      User = "jake";
      Group = "users";
      WorkingDirectory = "/home/jake/Videos/OBS/Code";
      Restart = "always";
      RestartSec = 10;
      LoadCredential = "GEMINI_API_KEY:/home/jake/.config/auto-transcriber.env";
    };

    script = ''
      ${pkgs.nix}/bin/nix-shell --run "python3 gemini_transcriber.py"
    '';
  };

  # This line closes the configuration set
}
