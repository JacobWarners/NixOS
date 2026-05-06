{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Replace "nixos" with your desired hostname
    networkmanager.enable = true;
#    networkmanager.dns = "none";
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
  services.mullvad-vpn.enable = true;

  # Apartment (home pfSense) WireGuard tunnel.
  # Config lives at /etc/wireguard/apartment.conf (root:root 600), not in
  # /nix/store, since it contains a private key. autostart=false so the
  # Waybar toggle owns lifecycle. Polkit rule (modules/polkit.nix) lets
  # wheel users start/stop wg-quick-apartment.service without sudo.
  networking.wg-quick.interfaces.apartment = {
    configFile = "/etc/wireguard/apartment.conf";
    autostart = false;
  };

  services.rpcbind.enable = true;
  # Import Wi-Fi secrets
  # imports = [ ../secrets/wifi.nix ];
}

