# ./modules/transcriber.nix
{ config, pkgs, ... }:

{
  systemd.services.python-transcriber = {
    # ... description, wantedBy, after, serviceConfig are all the same ...
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

    # This updated script tells nix-shell where to find the nix packages
    script = ''
      set -a
      source /home/jake/.config/python-transcriber.env
      set +a
      
      # The -I flag explicitly tells nix-shell where your system's packages are
      ${pkgs.nix}/bin/nix-shell -I nixpkgs=${pkgs.path} --run "python3 gemini_transcriber.py"
    '';
  };
}
