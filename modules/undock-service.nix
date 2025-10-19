# /path/to/your/egpu-recovery.nix
{ config, pkgs, ... }:

{
  # -- eGPU Hot-Unplug Recovery (Hybrid Service Method) --

  # 1. Enable TTYs so we have a recovery target.
  console.enable = true;
  services.greetd.vt = 1; # Keep graphical login on VT1.

  # 2. Define the systemd service that will perform the recovery.
  systemd.services.recover-on-undock = {
    description = "Remap console to internal display and switch to TTY on eGPU undock.";
    
    # Provide the paths to all the executables we need.
    path = [ pkgs.procps pkgs.coreutils pkgs.kbd ];

    serviceConfig = {
      Type = "oneshot";
      # THE ACTION:
      # 1. Forcefully kill the frozen Hyprland session.
      # 2. Pause for 1 second to let resources be released.
      # 3. CRITICAL: Remap virtual console 2 (TTY2) to framebuffer 0 (eDP-1).
      # 4. Switch the active view to the now-correctly-mapped TTY2.
      ExecStart = ''
        /bin/sh -c "${pkgs.procps}/bin/pkill -9 -f '^${pkgs.hyprland}/bin/Hyprland' && ${pkgs.coreutils}/bin/sleep 1 && ${pkgs.kbd}/bin/con2fbmap 2 0 && ${pkgs.kbd}/bin/chvt 2"
      '';
    };
  };

  # 3. The udev rule that triggers the service.
  # This is the CONFIRMED WORKING trigger mechanism.
  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="recover-on-undock.service"
  '';
}
