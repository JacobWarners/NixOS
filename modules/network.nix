{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Replace "nixos" with your desired hostname
    networkmanager.enable = true;
    wireless.enable = false; # NetworkManager handles wireless
    extraHosts = 
    ''
192.168.122.181 server.kubernetes.local server
192.168.122.30 node-0.kubernetes.local node-0 10.200.0.0/24
192.168.122.207 node-1.kubernetes.local node-1 10.200.1.0/24
192.168.122.102 node-2.kubernetes.local node-2 10.200.2.0/24
    '';
  };

  # Import Wi-Fi secrets
  # imports = [ ../secrets/wifi.nix ];
}

