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
    extraHosts =
      ''
        192.168.5.55   ai.home.local
      '';
  };

  # Boot self-heal for the dock-aware WiFi kill above.
  # NetworkManager PERSISTS WirelessEnabled to
  # /var/lib/NetworkManager/NetworkManager.state. If a session ends while
  # docked (radio off was saved), the next boot reads it back as OFF even
  # when undocked -- and the dispatcher's "down" branch never fires because
  # the dock NIC was never "up". Result: WiFi stranded off on boot.
  # This oneshot forces the radio on at boot UNLESS the dock NIC is actually
  # present and up. If docked, the dispatcher's "up" branch re-kills it, so
  # docked boots still end with WiFi off.
  systemd.services.wifi-unstick = {
    description = "Restore WiFi radio on boot unless docked";
    after = [ "NetworkManager.service" ];
    wants = [ "NetworkManager.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig.Type = "oneshot";
    script = ''
      dock=/sys/class/net/enp195s0f3u1u4
      if [ -e "$dock" ] && [ "$(cat "$dock/operstate" 2>/dev/null)" = "up" ]; then
        exit 0
      fi
      ${pkgs.networkmanager}/bin/nmcli radio wifi on
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

