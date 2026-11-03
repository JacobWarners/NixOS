# modules/egpu-dock.nix -- system side of the eGPU dock/undock flow.
# Replaces modules/egpu-eject.nix (same egpu-eject script, kept verbatim).
#
#  egpu-eject            root: orderly sysfs remove of the external amdgpu device
#  egpu-free-dead-fds    root: release fds that still point at a removed DRM node
#                        (gdb dup2 eventfd), so the slot can be reused on replug
#  egpu-unplug-watch     udev -> systemd: on a SURPRISE unplug of the eGPU, free
#                        dead fds, drop a marker and tell the user what it means
#
# The user-side script (Super+U) lives in home/ (egpu-dock, writeShellApplication).
{ config, pkgs, lib, ... }:

let
  egpuPci = "0000:64:00.0";   # Navi 23 in the Razer Core X Chroma
  igpuPci = "0000:c1:00.0";   # Krackan 860M, never touched
  user    = "jake";

  egpu-eject = pkgs.writeShellScriptBin "egpu-eject" ''
    set -u
    IGPU="${igpuPci}"
    rc=1
    for dev in /sys/bus/pci/drivers/amdgpu/0000:*; do
      [ -e "$dev" ] || continue
      addr=$(${pkgs.coreutils}/bin/basename "$dev")
      [ "$addr" = "$IGPU" ] && continue
      ${pkgs.coreutils}/bin/mkdir -p /run/egpu-dock && ${pkgs.coreutils}/bin/touch /run/egpu-dock/clean-eject   # tells egpu-unplug-watch this removal is ours
      # Sibling functions first (HDMI audio 64:00.1, snd_hda_intel). Left bound, the later cable pull
      # surprise-removes it and pciehp can wedge in snd_card_free (kernel hang 2026-11-02 17:01).
      for fn in "/sys/bus/pci/devices/''${addr%.*}".[1-7]; do
        [ -e "$fn" ] || continue
        echo "egpu-eject: removing $(${pkgs.coreutils}/bin/basename "$fn") (sibling function)"
        echo on > "$fn/power/control" 2>/dev/null || true
        echo 1 > "$fn/remove" || echo "egpu-eject: warning: could not remove $(${pkgs.coreutils}/bin/basename "$fn")" >&2
      done
      echo "egpu-eject: removing $addr"
      echo on > "/sys/bus/pci/devices/$addr/power/control" 2>/dev/null || true
      ${pkgs.coreutils}/bin/sleep 0.5
      echo 1 > "/sys/bus/pci/devices/$addr/remove" && rc=0
    done
    [ "$rc" -eq 0 ] || echo "egpu-eject: no external amdgpu device found" >&2
    exit "$rc"
  '';

  egpu-free-dead-fds = pkgs.writeShellApplication {
    name = "egpu-free-dead-fds";
    runtimeInputs = [ pkgs.gdb pkgs.coreutils pkgs.gnugrep ];
    text = builtins.readFile ./scripts/egpu-free-dead-fds.sh;
  };

  # Runs as root from udev. Notifies the user's session over its D-Bus socket.
  unplugWatch = pkgs.writeShellApplication {
    name = "egpu-unplug-watch";
    runtimeInputs = [ egpu-free-dead-fds pkgs.coreutils pkgs.util-linux pkgs.libnotify pkgs.sudo ];
    text = ''
      logger -t egpu-unplug-watch "eGPU ${egpuPci} left the bus"
      # Clean eject: egpu-dock already disabled outputs and will free fds itself;
      # the marker file is how it tells us so.
      if [ -e /run/egpu-dock/clean-eject ]; then
        rm -f /run/egpu-dock/clean-eject
        exit 0
      fi
      sleep 2   # let the compositor process the udev remove first
      out=$(egpu-free-dead-fds 2>&1 || true)
      logger -t egpu-unplug-watch "$out"
      mkdir -p /run/egpu-dock; date +%s > /run/egpu-dock/dirty
      uid=$(id -u ${user})
      sudo -u ${user} DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$uid/bus" \
        notify-send -a egpu-dock -u critical -t 30000 \
        "eGPU unplugged WITHOUT Super+U" \
        "Dead handles released. Hyprland may now hold ghost outputs: next redock can need a logout. Run: egpu-dock status" || true
    '';
  };
in
{
  environment.systemPackages = [ egpu-eject egpu-free-dead-fds pkgs.gdb ];

  security.sudo.extraConfig = ''
    ${user} ALL=(root) NOPASSWD: ${egpu-eject}/bin/egpu-eject, /run/current-system/sw/bin/egpu-eject
    ${user} ALL=(root) NOPASSWD: ${egpu-free-dead-fds}/bin/egpu-free-dead-fds, /run/current-system/sw/bin/egpu-free-dead-fds
  '';

  systemd.tmpfiles.rules = [ "d /run/egpu-dock 0755 root root -" ];

  # Fires on ANY removal of the eGPU's PCI function (clean or yanked); the
  # service sorts out which it was via the clean-eject marker.
  services.udev.extraRules = ''
    # SYSTEMD_WANTS is only honoured on add/change (device units never start on remove); verified
    # 2026-11-03: the service never ran on a real pull. RUN+= with --no-block is the supported way.
    ACTION=="remove", SUBSYSTEM=="pci", KERNEL=="${egpuPci}", RUN+="${pkgs.systemd}/bin/systemctl --no-block start egpu-unplug-watch.service"
  '';

  systemd.services.egpu-unplug-watch = {
    description = "eGPU surprise-unplug handler";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${unplugWatch}/bin/egpu-unplug-watch";
    };
  };
}
