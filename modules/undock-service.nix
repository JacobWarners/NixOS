# This is the complete file.
{ config, pkgs, ... }:

{
  # -- eGPU Hot-Unplug Recovery --

  # 1. Enable TTYs so we have a recovery target.

  # 2. Grant the udev daemon access to the programs we need to run.
  #    This is REQUIRED by NixOS for security and is what fixes the build error.
  services.udev.packages = [ pkgs.coreutils pkgs.procps pkgs.kbd ];

  # 3. The udev rule that triggers our recovery script directly.
  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", RUN+="${pkgs.coreutils}/bin/sh -c \"(${pkgs.procps}/bin/pkill -9 -f '^${pkgs.hyprland}/bin/Hyprland' && ${pkgs.coreutils}/bin/sleep 1 && ${pkgs.kbd}/bin/con2fbmap 2 0 && ${pkgs.kbd}/bin/chvt 2) &\""
  '';
}
