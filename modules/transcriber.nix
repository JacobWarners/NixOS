# ./modules/transcriber.nix

{ config, pkgs, ... }:

{
  # This line is the start of the configuration set
  
  systemd.services.python-transcriber = {
    description = "Watches the OBS folder and transcribes new videos";
    wantedBy = [ "multi-user.target" ];
    after = [ "network.target" ];

    serviceConfig = {
      User = "jake";
      Group = "users";
      WorkingDirectory = "/home/jake/Videos/OBS/Code";
      Restart = "always";
      RestartSec = 10;
      EnvironmentFile = "/home/jake/.config/python-transcriber.env";
    };

    script = ''
     # ./modules/transcriber.nix
     ...

      script = ''
           # This command will print the API key to the log if it exists, or an error if it doesn't.
           ${pkgs.nix}/bin/nix-shell --run "python3 -c 'import os; print(\"API Key found: \" + os.getenv(\"GEMINI_API_KEY\", \"KEY NOT FOUND\"))'"
            '';
  };

}
