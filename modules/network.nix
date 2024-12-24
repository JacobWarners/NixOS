{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Replace "nixos" with your desired hostname
    networkmanager.enable = true;
    wireless.enable = false; # NetworkManager handles wireless
    extraHosts = 
    ''
    192.168.10.120 homeassistant.local matterserver.local
    192.168.10.121 homeassistant.local matterserver.local
    '';
  };

  # Import Wi-Fi secrets
  # imports = [ ../secrets/wifi.nix ];
}

