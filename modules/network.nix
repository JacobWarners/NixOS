{ config, pkgs, ... }:

{
  networking.networkmanager.enable = true;
  networking.wireless.enable = false; # NetworkManager handles wireless

  # Import Wi-Fi secrets
  imports = [ ../secrets/wifi.nix ];
}

