{ config, pkgs, ... }:

{
  networking = {
    hostName = "nixos"; # Replace "nixos" with your desired hostname
    networkmanager.enable = true;
    #    networkmanager.dns = "none";
    # DNS strategy (declarative, single owner = resolvconf):
    #   * Primary  = the LAN gateway, learned from DHCP via NetworkManager
    #     (192.168.5.1 docked / 192.168.10.1 on wifi). Dock-aware for free.
    #   * Fallback = Quad9, appended AFTER the gateway via resolvconf's
    #     name_servers_append (openresolv). resolvconf regenerates resolv.conf
    #     deterministically on every event, so the fallback is never lost.
    # No static `nameservers` here on purpose -- a hardcoded primary went dead
    # whenever undocked onto wifi. VPN (Mullvad/Cato) prepends its own resolver
    # only while connected; on disconnect the gateway+Quad9 list remains.
    resolvconf.extraConfig = ''
      name_servers_append="9.9.9.9 149.112.112.112 2620:fe::fe 2620:fe::9"
    '';
    # Dock-aware WiFi drop: when the wired dock NIC comes up, disconnect the
    # WiFi *device* (runtime autoconnect block + disconnect) so its
    # 192.168.10.x IP stops being a WebRTC/ICE candidate and its resolver
    # leaves resolv.conf. Dual-homed (.5 wired + .10 WiFi) broke PairDrop
    # P2P and put the WiFi-only resolver first in DNS. Undock -> WiFi back.
    #
    # Deliberately NOT `nmcli radio wifi off`: that persists
    # WirelessEnabled=false to /var/lib/NetworkManager/NetworkManager.state,
    # so a reboot while docked came up with WiFi dead when undocked (the old
    # wifi-unstick oneshot raced NM init and lost, 2026-09-02). Device-level
    # autoconnect blocks are runtime-only: every boot starts clean.
    # `radio wifi on` in the down branch is a no-op normally and rescues any
    # leftover soft-block.
    networkmanager.logLevel = "INFO";
    networkmanager.dispatcherScripts = [{
      source = pkgs.writeShellScript "wifi-off-when-docked" ''
        iface="$1"; action="$2"
        [ "$iface" = "enp195s0f3u1u4" ] || exit 0
        nm=${pkgs.networkmanager}/bin/nmcli
        case "$action" in
          up)
            $nm device set wlp192s0 autoconnect no
            $nm -w 5 device disconnect wlp192s0 || true
            ;;
          down)
            $nm radio wifi on
            $nm device set wlp192s0 autoconnect yes
            $nm -w 5 device connect wlp192s0 || true
            ;;
        esac
      '';
      type = "basic";
    }];
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

