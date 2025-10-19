
{ config, pkgs, ... }:
{

  systemd.services.kill-hyprland-on-undock = {
    description = "Forcefully terminate Hyprland session for eGPU undock recovery.";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.procps}/bin/pkill -9 -x -f '.Hyprland-wrapped'";
    };
  };

  services.udev.extraRules = ''
    # Target the 'unbind' action on the exact DEVPATH of the parent Thunderbolt PCI bridge.
    # This is immune to the race condition that was causing previous attempts to fail.
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="kill-hyprland-on-undock.service"
  '';

}
