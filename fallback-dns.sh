#!/usr/bin/env bash
# fallback-dns.sh — get DNS working again WITHOUT the VPN.
# Framework workstation, NixOS host `nixos`.
# Maintained by Claude. Last updated: 2026-06-29 (v2: resolver probe).
# NOTE: this only RESTORES correct config; DNS only actually works if a
# reachable resolver exists. As of Jun 29 pfSense Unbound (192.168.5.1:53) is
# refusing, so off-VPN DNS stays dead until that gateway resolver is fixed.
#
# WHY THIS EXISTS:
#   Several things fight over /etc/resolv.conf — resolvconf (NixOS
#   networking.nameservers), NetworkManager (DHCP gateway DNS), the Mullvad
#   daemon (10.64.0.1), and Cato (10.254.254.1, and it core-dumps on exit).
#   When one of them leaves a dead resolver behind, ALL name lookups die.
#   This script forces a known-good state: LAN gateway first, Quad9 fallback,
#   VPN OFF.
#
# WHAT --apply DOES:
#   1. Disconnect Mullvad   (so you are NOT forced onto VPN DNS 10.64.0.1)
#   2. Stop cato-client     (clears its 10.254.254.1 resolver)
#   3. Write /etc/resolv.conf:
#        primary  = real LAN gateway, auto-detected from the default route
#                   (192.168.5.1 docked / 192.168.10.1 on wifi)
#        fallback = Quad9  9.9.9.9 / 149.112.112.112  (+ IPv6)
#   4. Test resolution.
#
#   No flag = DRY RUN: prints what it WOULD do, changes nothing.
#   For real:  sudo /home/jake/nixos-config/fallback-dns.sh --apply
#
# NOTE: this is an emergency get-unstuck tool. A NetworkManager event may later
#       re-stamp resolv.conf; if DNS breaks again just re-run it. The permanent
#       fix lives in the NixOS config (modules/network.nix) + pfSense.
set -uo pipefail

APPLY=0
[ "${1:-}" = "--apply" ] && APPLY=1
say(){ printf '%s\n' "$*"; }

# --- detect the real LAN gateway, ignoring any VPN interface ---
GW=$(ip -4 route show default 2>/dev/null \
       | grep -vEi 'wg|tun|mullvad|cato' \
       | awk '/default/{print $3; exit}')
[ -z "$GW" ] && GW=192.168.5.1   # last-resort: docked home gateway

RESOLV="# Written by fallback-dns.sh ($([ $APPLY = 1 ] && echo APPLY || echo DRYRUN))
search local
nameserver $GW
nameserver 9.9.9.9
nameserver 149.112.112.112
nameserver 2620:fe::fe
nameserver 2620:fe::9
options edns0"

say "=== current /etc/resolv.conf ==="
cat /etc/resolv.conf 2>/dev/null || say "(missing)"
say ""
say "=== detected LAN gateway: $GW ==="
say "=== proposed /etc/resolv.conf ==="
say "$RESOLV"
say ""

if [ $APPLY -ne 1 ]; then
  say "DRY RUN — nothing changed. Apply with:  sudo $0 --apply"
  exit 0
fi

if [ "$(id -u)" -ne 0 ]; then
  say "ERROR: --apply needs root.  Run:  sudo $0 --apply"; exit 1
fi

say "-> disconnecting Mullvad"
mullvad disconnect 2>/dev/null || true
say "-> stopping cato-client"
systemctl stop cato-client 2>/dev/null || true
say "-> writing /etc/resolv.conf"
printf '%s\n' "$RESOLV" > /etc/resolv.conf

say "-> probing resolvers on port 53"
probe(){ timeout 2 bash -c "echo > /dev/tcp/$1/53" >/dev/null 2>&1 && echo "open" || echo "DOWN / refused"; }
say "   gateway $GW : $(probe "$GW")"
say "   9.9.9.9       : $(probe 9.9.9.9)"

say "-> testing real lookups"
ok=0
for h in github.com ha.root-beards.com; do
  if getent hosts "$h" >/dev/null 2>&1; then say "   OK   $h"; ok=$((ok+1)); else say "   FAIL $h"; fi
done
say ""
if [ $ok -gt 0 ]; then
  say "DNS works ($ok resolved) with VPN OFF."
else
  say "NO DNS off-VPN. Config is correct, but no resolver is reachable:"
  say "  - gateway $GW:53 down  => pfSense DNS Resolver (Unbound) likely stopped"
  say "  - external 53 may be firewalled by pfSense"
  say "STOPGAP until pfSense is fixed:  mullvad connect"
fi
