{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Replace "nixos" with your desired hostname
    networkmanager.enable = true;
    networkmanager.dns = "none";
    nameservers = [ 
        "192.168.5.1" 
        "2620:119:35::35"
        "2620:119:53::53"
      ];
    wireless.enable = false; # NetworkManager handles wireless
    extraHosts =
      ''
        192.168.5.55   ai.home.local
      '';
  };

  services.rpcbind.enable = true;
  # Import Wi-Fi secrets
  # imports = [ ../secrets/wifi.nix ];
}

