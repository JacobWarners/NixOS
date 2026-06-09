{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Replace "nixos" with your desired hostname
    networkmanager.enable = true;
#    networkmanager.dns = "none";
    # Dock-aware WiFi kill: when the wired dock NIC comes up, turn the WiFi
    # radio OFF so its 192.168.10.x IP stops being a WebRTC/ICE candidate.
    # Dual-homed (.5 wired + .10 WiFi) breaks PairDrop P2P — ICE replies
    # leave the wrong NIC. Undock (wired down) -> WiFi back on.
    networkmanager.dispatcherScripts = [{
      source = pkgs.writeShellScript "wifi-off-when-docked" ''
        iface="$1"; action="$2"
        [ "$iface" = "enp195s0f3u1u4" ] || exit 0
        case "$action" in
          up)   ${pkgs.networkmanager}/bin/nmcli radio wifi off ;;
          down) ${pkgs.networkmanager}/bin/nmcli radio wifi on  ;;
        esac
      '';
      type = "basic";
    }];
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

