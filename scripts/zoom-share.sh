#!/usr/bin/env bash
# Pipes screen capture to a virtual camera for Zoom screen sharing.
# Bypasses Zoom's broken PipeWire re-share bug.
#
# Usage:
#   zoom-share.sh start       # Capture full output (auto-detects primary)
#   zoom-share.sh start DP-11 # Capture specific output
#   zoom-share.sh pick        # Use slurp to select a region
#   zoom-share.sh stop        # Stop capturing
#   zoom-share.sh status      # Check if running
#
# In Zoom: Share Screen > Advanced > Content from 2nd Camera > Switch Camera

set -euo pipefail

DEVICE="/dev/video10"
PIDFILE="/tmp/zoom-share.pid"

start_capture() {
  if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
    echo "Already running (PID $(cat "$PIDFILE")). Run 'zoom-share.sh stop' first."
    exit 1
  fi

  if [[ ! -e "$DEVICE" ]]; then
    echo "Error: $DEVICE not found. Is v4l2loopback loaded?"
    echo "Try: sudo modprobe v4l2loopback devices=1 video_nr=10 card_label='Screen Share' exclusive_caps=1"
    exit 1
  fi

  local args=()

  if [[ "${1:-}" == "pick" ]]; then
    local geometry
    geometry=$(slurp 2>/dev/null) || { echo "Selection cancelled"; exit 1; }
    args+=(-g "$geometry")
  elif [[ -n "${1:-}" ]]; then
    args+=(-o "$1")
  fi

  wf-recorder "${args[@]}" --muxer=v4l2 --codec=rawvideo --file="$DEVICE" -x yuv420p &
  local pid=$!
  echo "$pid" > "$PIDFILE"

  notify-send "Screen Share" "Capture started (PID $pid)" -t 3000 2>/dev/null || true
  echo "Capture started (PID $pid) -> $DEVICE"
  echo "In Zoom: Share Screen > Advanced > Content from 2nd Camera"
}

stop_capture() {
  if [[ -f "$PIDFILE" ]]; then
    local pid
    pid=$(cat "$PIDFILE")
    if kill -0 "$pid" 2>/dev/null; then
      kill "$pid"
      echo "Stopped capture (PID $pid)"
      notify-send "Screen Share" "Capture stopped" -t 2000 2>/dev/null || true
    else
      echo "Process $pid not running"
    fi
    rm -f "$PIDFILE"
  else
    # Kill any stray wf-recorder writing to our device
    pkill -f "wf-recorder.*$DEVICE" 2>/dev/null && echo "Stopped" || echo "Not running"
  fi
}

case "${1:-help}" in
  start)
    start_capture "${2:-}"
    ;;
  pick)
    start_capture "pick"
    ;;
  stop)
    stop_capture
    ;;
  status)
    if [[ -f "$PIDFILE" ]] && kill -0 "$(cat "$PIDFILE")" 2>/dev/null; then
      echo "Running (PID $(cat "$PIDFILE"))"
    else
      echo "Not running"
    fi
    ;;
  *)
    echo "Usage: zoom-share.sh {start [output]|pick|stop|status}"
    echo ""
    echo "  start          Capture primary output"
    echo "  start DP-11    Capture specific output"
    echo "  pick           Select region with slurp"
    echo "  stop           Stop capture"
    echo "  status         Check if running"
    ;;
esac
