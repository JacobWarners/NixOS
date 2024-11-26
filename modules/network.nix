{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Replace "nixos" with your desired hostname
    networkmanager.enable = true;
    wireless.enable = false; # NetworkManager handles wireless
  };

  # Import Wi-Fi secrets
  # imports = [ ../secrets/wifi.nix ];
}

