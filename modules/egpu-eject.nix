{ config, pkgs, ... }:

let
  # Orderly software eject of the Thunderbolt eGPU so the cable can be pulled
  # without amdgpu seeing "device lost from bus!" (2026-10-14 incident: dirty
  # teardown left Hyprland holding stale buffers -> SIGABRT 22 min later).
  #
  # Finds every amdgpu-bound PCI device that is NOT the internal iGPU
  # (c1:00.0, Krackan 860M) and removes it through sysfs. That runs the
  # driver's real .remove path, so the DRM node disappears cleanly and
  # Hyprland/aquamarine gets a normal device-removed event. Called via sudo
  # from the user-side `egpu-dock` script after the outputs are disabled.
  egpu-eject = pkgs.writeShellScriptBin "egpu-eject" ''
    set -u
    IGPU="0000:c1:00.0"
    rc=1
    for dev in /sys/bus/pci/drivers/amdgpu/0000:*; do
      [ -e "$dev" ] || continue
      addr=$(${pkgs.coreutils}/bin/basename "$dev")
      [ "$addr" = "$IGPU" ] && continue
      echo "egpu-eject: removing $addr"
      # Make sure it is awake (BACO runtime-pm) before tearing down.
      echo on > "/sys/bus/pci/devices/$addr/power/control" 2>/dev/null || true
      ${pkgs.coreutils}/bin/sleep 0.5
      echo 1 > "/sys/bus/pci/devices/$addr/remove" && rc=0
    done
    [ "$rc" -eq 0 ] || echo "egpu-eject: no external amdgpu device found" >&2
    exit "$rc"
  '';
in
{
  environment.systemPackages = [ egpu-eject ];

  # Only this one store-path script, no wildcard.
  security.sudo.extraConfig = ''
    jake ALL=(root) NOPASSWD: ${egpu-eject}/bin/egpu-eject, /run/current-system/sw/bin/egpu-eject
  '';
}
