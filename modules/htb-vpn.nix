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
# Profiles: HTB hands out a different .ovpn per product (Starting Point vs
# Machines vs ...). Each lives at /etc/openvpn/htb/<name>.ovpn, root:root 0600,
# NOT in the nix store or git (same pattern as /etc/wireguard/apartment.conf).
# The directory itself is root:wheel 0750 so `htb-vpn` can list the names.
# One systemd template instance per profile: openvpn-htb@<name>.service.
# Switching = stop one instance, start another; no root copy, polkit lets
# wheel do it without a password.
#
# Add a profile once:
#   sudo install -m600 -o root -g root ~/Downloads/machines_us-3.ovpn /etc/openvpn/htb/machines-us-3.ovpn
#
# Usage:  cd ~/home-ai/work/htb     (direnv starts netns + default profile)
#         htb-shell [profile]       (enter the VPN shell)
#         htb-vpn                   (list profiles, mark the active one)
#         htb-vpn <profile>         (switch; works from inside the shell too)
#         htb-status / htb-down

let
  ns = "htb";
  hostIf = "veth-htb";
  nsIf = "veth-htb-ns";
  subnet = "10.200.200.0/24";
  hostIp = "10.200.200.1";
  nsIp = "10.200.200.2";
  profileDir = "/etc/openvpn/${ns}";
  defaultProfile = "machines-us-3";
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

  # Shell snippets shared by the user-facing commands below.
  # htb_active: print the names of running profile instances, one per line.
  # htb_wait_tun0: block until tun0 has an IPv4 address (or fail after 30s).
  shellLib = ''
    htb_active() {
      systemctl list-units --state=active,activating --plain --no-legend 'openvpn-${ns}@*.service' \
        | ${pkgs.gawk}/bin/awk '{print $1}' \
        | ${pkgs.gnused}/bin/sed -E 's/^openvpn-${ns}@(.*)\.service$/\1/'
    }
    htb_tun0_up() {
      sudo -n ${htb-run}/bin/htb-run ${ip} -4 -o addr show dev tun0 2>/dev/null | grep -q inet
    }
    htb_wait_tun0() {
      printf 'htb: waiting for tun0'
      for _ in $(seq 1 30); do
        if htb_tun0_up; then echo " up"; return 0; fi
        printf '.'; sleep 1
      done
      echo
      echo "htb: tun0 never came up. journalctl -u 'openvpn-${ns}@*' -n 30" >&2
      return 1
    }
  '';

  htb-vpn = pkgs.writeShellScriptBin "htb-vpn" ''
    set -euo pipefail
    ${shellLib}

    if [ $# -eq 0 ]; then
      active="$(htb_active || true)"
      echo "profiles in ${profileDir} (* = active, default = ${defaultProfile}):"
      found=0
      for f in ${profileDir}/*.ovpn; do
        [ -e "$f" ] || continue
        found=1
        n="$(basename "$f" .ovpn)"
        mark=" "
        echo "$active" | grep -qx "$n" && mark="*"
        echo "  $mark $n"
      done
      [ $found = 1 ] || echo "  (none -- sudo install -m600 -o root -g root <file>.ovpn ${profileDir}/<name>.ovpn)"
      exit 0
    fi

    prof="$1"
    case "$prof" in
      *[!A-Za-z0-9_-]*|"")
        echo "htb-vpn: bad profile name '$prof' (allowed: A-Z a-z 0-9 _ -)" >&2; exit 2 ;;
    esac
    if [ ! -e "${profileDir}/$prof.ovpn" ]; then
      echo "htb-vpn: no such profile '$prof' (${profileDir}/$prof.ovpn). Run htb-vpn to list." >&2; exit 1
    fi

    systemctl start netns-${ns}.service
    for cur in $(htb_active || true); do
      if [ "$cur" = "$prof" ]; then
        echo "htb: profile '$prof' already active"
        htb_wait_tun0
        exit 0
      fi
      echo "htb: stopping profile '$cur'"
      systemctl stop "openvpn-${ns}@$cur.service"
    done
    echo "htb: starting profile '$prof'"
    systemctl start "openvpn-${ns}@$prof.service"
    htb_wait_tun0
    sudo -n ${htb-run}/bin/htb-run ${ip} -br -4 addr show dev tun0
  '';

  htb-shell = pkgs.writeShellScriptBin "htb-shell" ''
    set -euo pipefail
    ${shellLib}

    # Profile: argument > whatever is already running > default.
    prof="''${1:-}"
    if [ -z "$prof" ]; then
      prof="$(htb_active | head -n1 || true)"
      [ -n "$prof" ] || prof=${defaultProfile}
    fi
    ${htb-vpn}/bin/htb-vpn "$prof"

    echo "htb: entering namespace '${ns}' (profile $prof) -- HTB ranges via tun0, everything else via WAN NAT"
    export HTB_NS=1 HTB_PROFILE="$prof"
    exec sudo -E -n ${htb-run}/bin/htb-run "''${SHELL:-${pkgs.zsh}/bin/zsh}"
  '';

  htb-status = pkgs.writeShellScriptBin "htb-status" ''
    ${shellLib}
    printf '%-14s %s\n' "netns-${ns}" "$(systemctl is-active netns-${ns}.service)"
    active="$(htb_active || true)"
    if [ -n "$active" ]; then
      for p in $active; do printf '%-14s %s (%s)\n' "openvpn-${ns}" "active" "$p"; done
    else
      printf '%-14s %s\n' "openvpn-${ns}" "inactive (htb-vpn <profile>)"
    fi
    if [ -e /run/netns/${ns} ]; then
      echo "--- addresses (netns ${ns}) ---"
      sudo -n ${htb-run}/bin/htb-run ${ip} -br -4 addr
      echo "--- routes (netns ${ns}) ---"
      sudo -n ${htb-run}/bin/htb-run ${ip} -4 route
    fi
    [ -n "''${HTB_NS:-}" ] && echo "this shell: INSIDE netns" || echo "this shell: host network"
  '';

  htb-down = pkgs.writeShellScriptBin "htb-down" ''
    ${shellLib}
    for p in $(htb_active || true); do
      systemctl stop "openvpn-${ns}@$p.service"
    done
    systemctl stop netns-${ns}.service
    echo "htb: VPN and namespace torn down"
  '';
in
{
  environment.systemPackages = [ pkgs.openvpn htb-run htb-vpn htb-shell htb-status htb-down ];

  # Resolver for processes run via `ip netns exec htb` (bind-mounted over
  # /etc/resolv.conf). Keeps HTB-side DNS off the host resolver entirely.
  environment.etc."netns/${ns}/resolv.conf".text = ''
    nameserver 9.9.9.9
    nameserver 149.112.112.112
  '';

  # Profile directory: wheel can list names, only root can read contents.
  systemd.tmpfiles.rules = [ "d ${profileDir} 0750 root wheel -" ];

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

  # Template: one instance per profile, openvpn-htb@<name>.service.
  # partOf: stopping the netns takes any running instance down with it.
  systemd.services."openvpn-${ns}@" = {
    description = "HTB OpenVPN profile %i inside netns ${ns}";
    requires = [ "netns-${ns}.service" ];
    after = [ "netns-${ns}.service" ];
    partOf = [ "netns-${ns}.service" ];
    unitConfig.ConditionPathExists = "${profileDir}/%i.ovpn";
    serviceConfig = {
      NetworkNamespacePath = "/run/netns/${ns}";
      BindReadOnlyPaths = [ "/etc/netns/${ns}/resolv.conf:/etc/resolv.conf" ];
      ExecStart = "${pkgs.openvpn}/bin/openvpn --config ${profileDir}/%i.ovpn";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };

  # wheel may start/stop/restart the netns unit and any profile instance
  # without a password (same pattern as wg-quick-apartment in polkit.nix).
  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
      if (action.id == "org.freedesktop.systemd1.manage-units" &&
          subject.isInGroup("wheel")) {
        var unit = action.lookup("unit");
        var verb = action.lookup("verb");
        if ((unit == "netns-${ns}.service" ||
             /^openvpn-${ns}@[A-Za-z0-9_-]+\.service$/.test(unit)) &&
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
