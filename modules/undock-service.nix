{ config, pkgs, ... }:
{
  # -- eGPU Hot-Unplug Recovery (Final Path Fix) --

  services.openssh.enable = true;

  systemd.services.kill-hyprland-on-undock = {
    description = "Forcefully terminate Hyprland session for eGPU undock recovery.";
    serviceConfig = {
      Type = "oneshot";
      # THE FIX IS HERE: We now use the full path to pkill.
      ExecStart = "${pkgs.procps}/bin/pkill -9 -x -f '.Hyprland-wrapped'";
    };
  };

  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="kill-hyprland-on-undock.service"
  '';
}
