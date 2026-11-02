#!/usr/bin/env bash
# egpu-free-dead-fds -- release file descriptors that still point at a REMOVED
# DRM device (/dev/dri/cardN or renderDN, shown as "(deleted)" in /proc).
#
# Why: while any process holds such an fd the kernel cannot free that DRM minor,
# so a re-plugged GPU lands on a new card number (card2 instead of card0). The
# compositor's per-process EGL device cache still says card0, the renderer for
# the new device never comes up, and the external monitors stay black.
#
# How: attach gdb to the process and dup2() an eventfd over each dead fd. The fd
# NUMBER stays occupied (nothing in the process can be confused by a reused
# number) but the DRM reference is dropped. An eventfd at 0 is never readable,
# so a poll loop on it stays quiet. Verified live on Hyprland and Xwayland
# 2026-11-02; both kept running.
#
# Usage: egpu-free-dead-fds [--dry-run] [--all]
#   default: only the compositor and Xwayland are touched, other holders are
#            reported and skipped (exit 2).  --all: touch every holder.
# Needs root (ptrace of a capability-bearing compositor).
set -u
GDB="${GDB:-gdb}"
DRY=0 ALL=0
for a in "$@"; do
  case "$a" in
    --dry-run) DRY=1 ;;
    --all) ALL=1 ;;
    *) echo "usage: $0 [--dry-run] [--all]" >&2; exit 64 ;;
  esac
done

rc=0 found=0
for fddir in /proc/[0-9]*/fd; do
  pid=${fddir#/proc/}; pid=${pid%/fd}
  [ "$pid" = "$$" ] && continue
  fds=()
  for f in "$fddir"/*; do
    l=$(readlink "$f" 2>/dev/null) || continue
    case "$l" in "/dev/dri/"*" (deleted)") fds+=("${f##*/}") ;; esac
  done
  [ ${#fds[@]} -gt 0 ] || continue
  found=1
  comm=$(cat "/proc/$pid/comm" 2>/dev/null || echo '?')
  maps=$(grep -c -E '/dev/dri/.*\(deleted\)' "/proc/$pid/maps" 2>/dev/null || true)
  maps=${maps:-0}
  echo "pid $pid ($comm): dead fds ${fds[*]}, dead maps $maps"
  case "$comm" in
    Hyprland|.Hyprland-wrap*|Xwayland) ;;
    *) if [ "$ALL" -ne 1 ]; then echo "  skipped: not the compositor (use --all)"; rc=2; continue; fi ;;
  esac
  if [ "$maps" != 0 ]; then
    echo "  skipped: memory maps still reference the device; an fd swap would not free it"
    rc=2; continue
  fi
  [ "$DRY" -eq 1 ] && { echo "  dry-run: would swap"; continue; }
  args=(-ex "set \$e = (int)eventfd(0, 0)")
  for fd in "${fds[@]}"; do args+=(-ex "call (int)dup2(\$e, $fd)"); done
  args+=(-ex "call (int)close(\$e)" -ex detach)
  if "$GDB" -q -batch -p "$pid" "${args[@]}" >/dev/null 2>&1; then
    for fd in "${fds[@]}"; do echo "  fd $fd -> $(readlink "/proc/$pid/fd/$fd" 2>/dev/null)"; done
  else
    echo "  gdb attach failed"; rc=1
  fi
done
[ "$found" -eq 1 ] || echo "no dead DRM fds"
exit "$rc"
