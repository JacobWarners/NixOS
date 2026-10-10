{ config, lib, pkgs, ... }:

# HackTheBox OpenVPN, isolated in a network namespace.
#
# Why a netns: direnv can only export env vars, and a host-wide OpenVPN would
# push HTB routes into every window. Running OpenVPN *inside* netns "htb" means
# tun0 only exists there. A shell entered with `htb-shell` (and every command
# Claude runs from it) is inside the VPN; every other terminal is untouched.
#
# Traffic inside the netns:
#   HTB lab ranges (pushed by the server) -> tun0 -> HTB
#   everything else -> veth -> host NAT -> regular WAN   (split tunnel)
#
# Secret: /etc/openvpn/htb.ovpn, root:root 0600, NOT in the nix store or git
# (same pattern as /etc/wireguard/apartment.conf).
#
# Usage:  cd ~/home-ai/bug-bounties/htb   (direnv starts the units)
#         htb-shell                        (enter the VPN shell)
#         htb-status / htb-down

let
  ns = "htb";
  hostIf = "veth-htb";
  nsIf = "veth-htb-ns";
  subnet = "10.200.200.0/24";
  hostIp = "10.200.200.1";
  nsIp = "10.200.200.2";
  ovpnConf = "/etc/openvpn/htb.ovpn";
  user = "jake";
  group = "users";

  ip = "${pkgs.iproute2}/bin/ip";
  ipt = "${pkgs.iptables}/bin/iptables";

  # Tear down everything, ignoring errors (used before up, and on stop).
  netnsDown = pkgs.writeShellScript "netns-${ns}-down" ''
    ${ipt} -t nat -D POSTROUTING -s ${subnet} ! -o ${hostIf} -j MASQUERADE 2>/dev/null || true
    ${ipt} -D FORWARD -i ${hostIf} -s ${subnet} -j ACCEPT 2>/dev/null || true
    ${ipt} -D FORWARD -o ${hostIf} -d ${subnet} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT 2>/dev/null || true
    ${ip} link del ${hostIf} 2>/dev/null || true
    ${ip} netns del ${ns} 2>/dev/null || true
  '';

  netnsUp = pkgs.writeShellScript "netns-${ns}-up" ''
    set -euo pipefail
    ${netnsDown}

    ${ip} netns add ${ns}
    ${ip} link add ${hostIf} type veth peer name ${nsIf}
    ${ip} link set ${nsIf} netns ${ns}

    ${ip} addr add ${hostIp}/24 dev ${hostIf}
    ${ip} link set ${hostIf} up

    ${ip} -n ${ns} link set lo up
    ${ip} -n ${ns} addr add ${nsIp}/24 dev ${nsIf}
    ${ip} -n ${ns} link set ${nsIf} up
    ${ip} -n ${ns} route add default via ${hostIp}

    # ping_group_range is per-netns and a fresh netns disables it ("1 0").
    ${ip} netns exec ${ns} ${pkgs.procps}/bin/sysctl -q -w net.ipv4.ping_group_range="0 2147483647"

    ${pkgs.procps}/bin/sysctl -q -w net.ipv4.ip_forward=1

    # Docker sets FORWARD policy DROP, so allow the veth explicitly (insert at top).
    ${ipt} -I FORWARD 1 -i ${hostIf} -s ${subnet} -j ACCEPT
    ${ipt} -I FORWARD 1 -o ${hostIf} -d ${subnet} -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT
    ${ipt} -t nat -A POSTROUTING -s ${subnet} ! -o ${hostIf} -j MASQUERADE
  '';

  # Root-only entry point (invoked via sudo, see security.sudo.extraConfig).
  # Runs a command as ${user} inside the namespace. Lives in the nix store so
  # the NOPASSWD rule points at a file the user cannot edit.
  htb-run = pkgs.writeShellScriptBin "htb-run" ''
    set -euo pipefail
    if [ "$(id -u)" != 0 ]; then
      echo "htb-run: must be invoked via sudo" >&2; exit 1
    fi
    if [ ! -e /run/netns/${ns} ]; then
      echo "htb-run: netns '${ns}' is not up (systemctl start netns-${ns}.service)" >&2; exit 1
    fi
    [ $# -gt 0 ] || set -- "''${SHELL:-${pkgs.zsh}/bin/zsh}"
    exec ${ip} netns exec ${ns} \
      ${pkgs.util-linux}/bin/setpriv --reuid=${user} --regid=${group} --init-groups -- "$@"
  '';

  htb-shell = pkgs.writeShellScriptBin "htb-shell" ''
    set -euo pipefail
    systemctl start netns-${ns}.service openvpn-${ns}.service

    printf 'htb: waiting for tun0'
    for _ in $(seq 1 30); do
      if sudo -n ${htb-run}/bin/htb-run ${ip} -4 -o addr show dev tun0 2>/dev/null | grep -q inet; then
        echo " up"
        break
      fi
      printf '.'; sleep 1
    done
    if ! sudo -n ${htb-run}/bin/htb-run ${ip} -4 -o addr show dev tun0 2>/dev/null | grep -q inet; then
      echo
      echo "htb: tun0 never came up. journalctl -u openvpn-${ns} -n 30" >&2
      exit 1
    fi

    echo "htb: entering namespace '${ns}' -- HTB ranges via tun0, everything else via WAN NAT"
    export HTB_NS=1
    exec sudo -E -n ${htb-run}/bin/htb-run "''${SHELL:-${pkgs.zsh}/bin/zsh}"
  '';

  htb-status = pkgs.writeShellScriptBin "htb-status" ''
    for u in netns-${ns} openvpn-${ns}; do
      printf '%-14s %s\n' "$u" "$(systemctl is-active $u.service)"
    done
    if [ -e /run/netns/${ns} ]; then
      echo "--- addresses (netns ${ns}) ---"
      sudo -n ${htb-run}/bin/htb-run ${ip} -br -4 addr
      echo "--- routes (netns ${ns}) ---"
      sudo -n ${htb-run}/bin/htb-run ${ip} -4 route
    fi
    [ -n "''${HTB_NS:-}" ] && echo "this shell: INSIDE netns" || echo "this shell: host network"
  '';

  htb-down = pkgs.writeShellScriptBin "htb-down" ''
    systemctl stop openvpn-${ns}.service netns-${ns}.service
    echo "htb: VPN and namespace torn down"
  '';
in
{
  environment.systemPackages = [ pkgs.openvpn htb-run htb-shell htb-status htb-down ];

  # Resolver for processes run via `ip netns exec htb` (bind-mounted over
  # /etc/resolv.conf). Keeps HTB-side DNS off the host resolver entirely.
  environment.etc."netns/${ns}/resolv.conf".text = ''
    nameserver 9.9.9.9
    nameserver 149.112.112.112
  '';

  systemd.services."netns-${ns}" = {
    description = "HTB network namespace with NAT uplink";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = netnsUp;
      ExecStop = netnsDown;
    };
  };

  systemd.services."openvpn-${ns}" = {
    description = "HTB OpenVPN inside netns ${ns}";
    requires = [ "netns-${ns}.service" ];
    after = [ "netns-${ns}.service" ];
    unitConfig.ConditionPathExists = ovpnConf;
    serviceConfig = {
      NetworkNamespacePath = "/run/netns/${ns}";
      BindReadOnlyPaths = [ "/etc/netns/${ns}/resolv.conf:/etc/resolv.conf" ];
      ExecStart = "${pkgs.openvpn}/bin/openvpn --config ${ovpnConf}";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # wheel may start/stop/restart the two units without a password (same
  # pattern as wg-quick-apartment in polkit.nix).
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.isInGroup("wheel")) {
        var unit = action.lookup("unit");
        var verb = action.lookup("verb");
        if ((unit == "netns-${ns}.service" || unit == "openvpn-${ns}.service") &&
            (verb == "start" || verb == "stop" || verb == "restart")) {
          return polkit.Result.YES;
        }
      }
    });
  '';

  # Only this one store-path script, not `ip netns exec *`. SETENV lets
  # `sudo -E` carry the nix-shell PATH/env into the namespace shell.
  security.sudo.extraConfig = ''
    ${user} ALL=(root) NOPASSWD:SETENV: ${htb-run}/bin/htb-run, /run/current-system/sw/bin/htb-run
  '';
}
