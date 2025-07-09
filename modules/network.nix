{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Replace "nixos" with your desired hostname
    networkmanager.enable = true;
    networkmanager.dns = "none";
    nameservers = [ "192.168.5.1" ];
    wireless.enable = false; # NetworkManager handles wireless
    extraHosts =
      ''
        192.168.5.55   ai.home.local
      '';
  };

  services.rpcbind.enable;
  # Import Wi-Fi secrets
  # imports = [ ../secrets/wifi.nix ];
}

