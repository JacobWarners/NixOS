{ config, pkgs, ... }:
{
  # -- eGPU Hot-Unplug Recovery (Complete) --

  services.openssh.enable = true;

  systemd.services.kill-hyprland-on-undock = {
    description = "Forcefully terminate Hyprland and restart the display manager.";
    # We need this to allow the service to restart another service.
    path = [ pkgs.systemd ];
    serviceConfig = {
      Type = "oneshot";
      # The final command: a chain of two actions.
      # 1. Kill the frozen Hyprland session.
      # 2. Restart the display-manager service to get a login screen.
      ExecStart = ''
        /bin/sh -c "${pkgs.procps}/bin/pkill -9 -f '^${pkgs.hyprland}/bin/Hyprland' && systemctl restart display-manager.service"
      '';
    };
  };

  # This udev rule is CONFIRMED WORKING. Do not change it.
  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="kill-hyprland-on-undock.service"
  '';
}
