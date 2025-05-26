{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Replace "nixos" with your desired hostname
    networkmanager.enable = true;
    nameservers = [ "192.168.5.1" ];
    wireless.enable = false; # NetworkManager handles wireless
    extraHosts =
      ''
        192.168.10.120 homeassistant.local matterserver.local
        192.168.10.121 homeassistant.local matterserver.local
        192.168.5.55   ai.home.local
      '';
  };

  # Import Wi-Fi secrets
  # imports = [ ../secrets/wifi.nix ];
}

