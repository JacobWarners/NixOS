systemd.services.auto-transcriber = {
  description = "Watches the OBS folder and transcribes new videos";
  # ... other settings are the same ...

  serviceConfig = {
    User = "jake";
    Group = "users";
    WorkingDirectory = "/home/jake/Videos/OBS/Code";
    Restart = "always";
    RestartSec = 10;
    
    # This is the new part: Securely load the API key from your .env file
    LoadCredential = "GEMINI_API_KEY:/home/jake/.config/auto-transcriber.env";
  };

  script = ''
    # The python script will now get the key from the environment
    ${pkgs.nix}/bin/nix-shell --run "python3 gemini_transcriber.py"
  '';
};

