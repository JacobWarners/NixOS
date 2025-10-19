# /path/to/your/egpu-recovery.nix
{ config, pkgs, ... }:

{
  # -- eGPU Hot-Unplug Recovery (Final Buildable Direct Execution Method) --

  # CRITICAL: This line tells the NixOS builder that the programs from
  # these packages are allowed to be used in udev RUN commands.
  # This will fix the build error.
  services.udev.packages = [ pkgs.coreutils pkgs.procps pkgs.kbd ];

  # The udev rule now has the necessary permissions to be built correctly.
  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", RUN+="${pkgs.coreutils}/bin/sh -c \"(${pkgs.procps}/bin/pkill -9 -f '^${pkgs.hyprland}/bin/Hyprland' && ${pkgs.coreutils}/bin/sleep 1 && ${pkgs.kbd}/bin/con2fbmap 2 0 && ${pkgs.kbd}/bin/chvt 2) &\""
  '';
}
