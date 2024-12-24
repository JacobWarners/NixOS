{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Replace "nixos" with your desired hostname
    networkmanager.enable = true;
    wireless.enable = false; # NetworkManager handles wireless
    extraHosts = 
    ''
    10.43.0.1 homeassistant.local matterserver.local
    '';
  };

  # Import Wi-Fi secrets
  # imports = [ ../secrets/wifi.nix ];
}

