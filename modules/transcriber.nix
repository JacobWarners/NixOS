# /etc/nixos/configuration.nix

{ config, pkgs, ... }:

{
  # ... your other existing configuration ...

  # Define the auto-transcriber background service
  systemd.services.auto-transcriber = {
    description = "Watches the OBS folder and transcribes new videos";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    # The main service configuration
    serviceConfig = {
      # The user and group the service will run as
      User = "jake";
      Group = "users";

      # The directory where your script and shell.nix are located
      WorkingDirectory = "/home/jake/Videos/OBS/"; # Make sure this path is correct!

      # Set the Gemini API Key securely for the service
      Environment = "GEMINI_API_KEY=YOUR_GEMINI_API_KEY"; # 👈 Paste your key here

      # For stability, always restart the service if it fails
      Restart = "always";
      RestartSec = 10;
    };

    # The command that the service will run on startup
    script = ''
      # We use the full path to nix-shell to be safe
      ${pkgs.nix}/bin/nix-shell --run "python3 gemini_transcriber.py"
    '';
  };

  # ... rest of your configuration ...
}
