# egpu-dock -- dock / undock the Thunderbolt eGPU under Hyprland without ever
# logging out. Decides by what the KERNEL says (sysfs), never by Hyprland's
# monitor list, and never calls `hyprctl reload`.
#
#   egpu-dock            toggle: eGPU outputs lit -> undock, dark -> redock
#   egpu-dock undock     disable outputs, verify, eject GPU, free dead fds, notify
#   egpu-dock redock     wait for GPU, enable each connected output BY NAME from
#                        the desc: rules in hyprland.conf, move workspaces, notify
#   egpu-dock status     one screen of truth (kernel, Hyprland, ghosts, holders)
#   egpu-dock recover    what to do when redock refused
#
# Runs under writeShellApplication: errexit, nounset, pipefail are on.
# Root helpers (sudo -n, NOPASSWD): egpu-eject, egpu-free-dead-fds.

EGPU_PCI="${EGPU_PCI:-0000:64:00.0}"
HYPR_CONF="${HYPR_CONF:-$HOME/.config/hypr/hyprland.conf}"
STATE_DIR="${XDG_CACHE_HOME:-$HOME/.cache}/egpu-dock"
DIRTY_MARK="$STATE_DIR/dirty"
mkdir -p "$STATE_DIR"

t0=$(date +%s.%N)
elapsed() { printf '%.1fs' "$(echo "$(date +%s.%N) - $t0" | bc)"; }
log() { echo "egpu-dock: $*" >&2; logger -t egpu-dock -- "$*" || true; }
notify() { # notify LEVEL TITLE BODY
  local lvl=$1 title=$2 body=$3 ms=6000
  [ "$lvl" = critical ] && ms=20000
  log "$title: $body"
  notify-send -a egpu-dock -u "$lvl" -t "$ms" "$title" "$body" 2>/dev/null || true
}
die() { notify critical "$1" "$2"; exit 1; }
# errexit safety net: never die silently again. Reports the failing line and command.
# errtrace: make the ERR trap fire inside functions too (writeShellApplication only sets errexit/nounset/pipefail).
set -o errtrace
# shellcheck disable=SC2154  # rc is assigned inside the trap string
trap 'rc=$?; trap - ERR; notify critical "egpu-dock: internal error (exit $rc)" "line $LINENO: $BASH_COMMAND\nMonitors untouched unless the notification above says otherwise. Run: egpu-dock status"; exit $rc' ERR

# ---------- kernel view ----------
egpu_on_bus() { [ -d "/sys/bus/pci/devices/$EGPU_PCI" ]; }
egpu_card() { # -> card0 | ""
  local c; for c in "/sys/bus/pci/devices/$EGPU_PCI"/drm/card*; do [ -e "$c" ] && { basename "$c"; return; }; done; echo ""
}
egpu_render() { local r; for r in "/sys/bus/pci/devices/$EGPU_PCI"/drm/renderD*; do [ -e "$r" ] && { basename "$r"; return; }; done; echo ""; }
egpu_connectors() { # connected connector names on the eGPU card, e.g. DP-11 HDMI-A-1
  local card=$1 c
  for c in /sys/class/drm/"$card"-*; do
    [ -e "$c/status" ] || continue
    if [ "$(cat "$c/status")" = connected ]; then basename "$c" | sed "s/^$card-//"; fi
  done
  return 0  # last connector is usually a disconnected one; never leak its test status into errexit
}
kernel_enabled() { cat "/sys/class/drm/$1-$2/enabled" 2>/dev/null || echo unknown; }
any_enabled() { local card=$1 c; for c in $(egpu_connectors "$card"); do [ "$(kernel_enabled "$card" "$c")" = enabled ] && return 0; done; return 1; }
wait_until() { # wait_until SECONDS CMD...
  local deadline=$(( $(date +%s) + $1 )); shift
  until "$@"; do [ "$(date +%s)" -ge "$deadline" ] && return 1; sleep 0.2; done
}
all_kernel_state() { # all_kernel_state CARD STATE conn...
  local card=$1 want=$2; shift 2; local c
  for c in "$@"; do [ "$(kernel_enabled "$card" "$c")" = "$want" ] || return 1; done
}

# ---------- Hyprland view ----------
hypr_json() { hyprctl monitors all -j; }
hypr_count_named() { hypr_json | jq -r --arg n "$1" '[.[] | select(.name==$n)] | length'; }
hypr_desc() { hypr_json | jq -r --arg n "$1" '[.[] | select(.name==$n)][0].description // empty'; }
hypr_log() { find "${XDG_RUNTIME_DIR:-/run/user/$UID}"/hypr -maxdepth 2 -name hyprland.log -printf "%T@ %p\n" 2>/dev/null | sort -rn | head -1 | cut -d" " -f2-; }
renderer_errors() { local l; l=$(hypr_log); if [ -n "$l" ]; then grep -c "Can't create renderer" "$l" || true; else echo 0; fi; }
# config lookups: "monitor=desc:<desc>, <mode>, <pos>, <scale>"  ->  "<mode>,<pos>,<scale>"
rule_for_desc() { { grep -E "^\s*monitor\s*=\s*desc:$(printf '%s' "$1" | sed 's/[][\.*^$]/\\&/g')\s*," "$HYPR_CONF" || true; } | head -1 | sed -E 's/^[^,]*,//; s/[[:space:]]//g'; }
ws_for_desc() { { grep -E "^\s*workspace\s*=.*monitor:desc:$(printf '%s' "$1" | sed 's/[][\.*^$]/\\&/g')\s*," "$HYPR_CONF" || true; } | head -1 | sed -E 's/^\s*workspace\s*=\s*([^,]+),.*/\1/; s/[[:space:]]//g'; }
# ghosts: Hyprland monitors whose name is not a live connector on any card
ghosts() { local n; for n in $(hypr_json | jq -r '.[].name'); do ls -d /sys/class/drm/card*-"$n" >/dev/null 2>&1 || echo "$n"; done; }

# ---------- holders ----------
holders() { # holders CARD RENDER -> "pid comm maps" for processes with the live nodes open (compositor + self excluded).
  # maps>0 = the process has GEM buffers mapped = it really renders there (a game) and would be yanked mid-frame.
  # maps=0 = it merely opened the node while enumerating GPUs (Chromium/Electron do this) and survives removal;
  # its dead fd is released afterwards by egpu-free-dead-fds --all.
  local card=$1 render=$2 f l pid comm
  for f in /proc/[0-9]*/fd/*; do
    l=$(readlink "$f" 2>/dev/null) || continue
    case "$l" in "/dev/dri/$card"|"/dev/dri/$render") ;; *) continue ;; esac
    pid=${f#/proc/}; pid=${pid%%/*}
    [ "$pid" = "$$" ] && continue
    comm=$(cat "/proc/$pid/comm" 2>/dev/null || echo '?')
    case "$comm" in Hyprland|.Hyprland-wrap*|Xwayland|egpu-dock) ;; *) echo "$pid $comm $(grep -c -E "/dev/dri/($card|$render)" "/proc/$pid/maps" 2>/dev/null || true)" ;; esac
  done | sort -u
}

# ---------- actions ----------
cmd_undock() {
  local card render conns c
  egpu_on_bus || die "eGPU undock" "No eGPU on the PCI bus. Already ejected? Pull the cable."
  card=$(egpu_card); render=$(egpu_render)
  [ -n "$card" ] || die "eGPU undock" "eGPU on bus but no DRM node (driver not bound). Check journalctl -k."
  # shellcheck disable=SC2207
  conns=($(egpu_connectors "$card"))
  for c in "${conns[@]}"; do hyprctl keyword monitor "$c,disable" >/dev/null; done
  wait_until 3 all_kernel_state "$card" disabled "${conns[@]}" || log "warning: kernel still shows an eGPU output enabled after 3s, continuing"
  local h active; h=$(holders "$card" "$render")
  active=$(printf '%s\n' "$h" | awk '$3 > 0 {print $1, $2}')
  [ -z "$active" ] || die "eGPU undock: still rendering on the eGPU" "Close these first, then Super+U again:\n$active"
  [ -z "$h" ] || log "note: idle openers of the eGPU node, released after eject: $(printf '%s' "$h" | tr '\n' ';')"
  sudo -n egpu-eject >/dev/null 2>&1 || die "eGPU undock: eject FAILED" "Do NOT unplug. Outputs are off; run: sudo egpu-eject"
  wait_until 5 bash -c "! [ -d /sys/bus/pci/devices/$EGPU_PCI ]" || die "eGPU undock: GPU still on bus after eject" "Do NOT unplug yet. Check journalctl -k."
  # free any handle still pinned on the dead node so the next plug lands on the same card number
  sudo -n egpu-free-dead-fds --all >/dev/null 2>&1 || log "note: egpu-free-dead-fds reported leftovers (see journal)"
  local g; g=$(ghosts | tr '\n' ' ')
  if [ -n "$g" ]; then
    touch "$DIRTY_MARK"
    notify critical "eGPU ejected, but Hyprland kept ghost outputs: $g" "Safe to unplug. Redock will need a logout. Better to log out now while nothing is open."
  else
    rm -f "$DIRTY_MARK"
    notify normal "eGPU ejected in $(elapsed) - safe to unplug" "Press Super+U after redocking."
  fi
}

cmd_redock() {
  local card conns c desc rule ws before
  before=$(renderer_errors)
  wait_until 15 egpu_on_bus || die "eGPU redock" "No eGPU on the PCI bus after 15s. Cable seated? Thunderbolt authorized?"
  wait_until 10 bash -c "[ -n \"\$(ls -d /sys/bus/pci/devices/$EGPU_PCI/drm/card* 2>/dev/null)\" ]" || die "eGPU redock" "GPU on bus but amdgpu did not bind within 10s. See journalctl -k."
  card=$(egpu_card)
  wait_until 5 bash -c "[ -n \"\$(for c in /sys/class/drm/$card-*; do [ \"\$(cat \$c/status 2>/dev/null)\" = connected ] && echo x; done)\" ]" || die "eGPU redock" "GPU is up ($card) but no monitor is connected to it."
  # shellcheck disable=SC2207
  conns=($(egpu_connectors "$card"))
  # ghost collision: same name twice in Hyprland = a dead copy from an earlier yank. Name rules would hit both.
  for c in "${conns[@]}"; do
    [ "$(hypr_count_named "$c")" -le 1 ] || die "eGPU redock refused: ghost output $c" "Hyprland still holds a dead $c from an unclean unplug. Enabling it would crash your apps. Logout required (nothing else fixes this)."
  done
  # give aquamarine a moment to register the new backend, then check it got a renderer
  sleep 1
  if [ "$(renderer_errors)" -gt "$before" ]; then
    die "eGPU redock refused: no renderer for $card" "GPU came back as $card and Hyprland cannot render to it. Run: egpu-dock recover"
  fi
  for c in "${conns[@]}"; do
    desc=$(hypr_desc "$c"); rule=""
    [ -n "$desc" ] && rule=$(rule_for_desc "$desc")
    [ -n "$rule" ] || { rule="preferred,auto,1"; log "no desc rule for $c ($desc), using $rule"; }
    hyprctl keyword monitor "$c,$rule" >/dev/null
  done
  wait_until 5 all_kernel_state "$card" enabled "${conns[@]}" || die "eGPU redock: outputs did not light" "Kernel shows them still disabled. Renderer errors: $(renderer_errors). Run: egpu-dock status"
  for c in "${conns[@]}"; do
    desc=$(hypr_desc "$c"); ws=""; [ -n "$desc" ] && ws=$(ws_for_desc "$desc")
    [ -n "$ws" ] && hyprctl dispatch moveworkspacetomonitor "$ws" "$c" >/dev/null
  done
  rm -f "$DIRTY_MARK"
  notify normal "eGPU redocked in $(elapsed)" "$card: ${conns[*]}"
}

cmd_status() {
  echo "eGPU PCI $EGPU_PCI: $(egpu_on_bus && echo on-bus || echo absent)"
  local card; card=$(egpu_card)
  if [ -n "$card" ]; then
    echo "DRM: $card $(egpu_render)"
    local c; for c in $(egpu_connectors "$card"); do echo "  $c kernel=$(kernel_enabled "$card" "$c") hypr_entries=$(hypr_count_named "$c") desc=$(hypr_desc "$c")"; done
    echo "openers of eGPU nodes (pid comm maps; maps>0 blocks undock): $(holders "$card" "$(egpu_render)" | tr "\n" ";")"
  fi
  echo "ghost outputs in Hyprland: $(ghosts | tr '\n' ' ')"
  echo "dead DRM fds (own processes): $(for f in /proc/[0-9]*/fd/*; do l=$(readlink "$f" 2>/dev/null) || continue; case "$l" in *dri*deleted*) p=${f#/proc/}; echo "${p%%/*}";; esac; done | sort -u | tr '\n' ' ')"
  echo "renderer errors in Hyprland log: $(renderer_errors)"
  echo "dirty marker: $([ -e "$DIRTY_MARK" ] && echo yes || echo no)"
  echo "hyprland monitors:"; hypr_json | jq -r '.[] | "  id=\(.id) \(.name) disabled=\(.disabled) \(.width)x\(.height) \(.description)"'
}

cmd_recover() {
  cat <<TXT
Redock was refused. Two possible states:

1. "no renderer for cardN": the GPU came back on a different card number than
   the one Hyprland remembers (something held the dead node open).
     a) pull the cable
     b) sudo egpu-free-dead-fds        (frees the pinned slot)
     c) plug the cable, wait 5 s, Super+U
2. "ghost output": an earlier unclean unplug left a dead copy of the monitor in
   Hyprland. Nothing but a logout clears it. Do it now, cable in, nothing open.

Current state:
TXT
  cmd_status
}

case "${1:-toggle}" in
  undock) cmd_undock ;;
  redock) cmd_redock ;;
  status) cmd_status ;;
  recover) cmd_recover ;;
  toggle)
    if ! egpu_on_bus; then
      die "eGPU" "No eGPU on the bus. Plug the cable in, wait 5 s, press Super+U again."
    fi
    card=$(egpu_card)
    if [ -n "$card" ] && any_enabled "$card"; then cmd_undock; else cmd_redock; fi ;;
  *) echo "usage: egpu-dock [undock|redock|status|recover]" >&2; exit 64 ;;
esac
