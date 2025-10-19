# /path/to/your/egpu-recovery.nix
{ config, pkgs, ... }:

{
  # -- eGPU Hot-Unplug Recovery (Final Direct Execution Method) --

  # 1. Enable TTYs so we have a recovery target.

  # 2. The complete udev rule. It bypasses the deadlocked systemd service
  #    manager by executing the recovery commands DIRECTLY when the
  #    hardware event is detected.
  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", RUN+="${pkgs.coreutils}/bin/sh -c '(${pkgs.procps}/bin/pkill -9 -f ''^${pkgs.hyprland}/bin/Hyprland'' && ${pkgs.coreutils}/bin/sleep 1 && ${pkgs.kbd}/bin/con2fbmap 2 0 && ${pkgs.kbd}/bin/chvt 2) &'"
  '';
}
