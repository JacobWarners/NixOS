{ config, pkgs, ... }:
{
  systemd.services.kill-hyprland-on-undock = {
    description = "Forcefully terminate Hyprland and restart the display manager.";
    path = [ pkgs.systemd ];
    serviceConfig = {
      Type = "oneshot";
      # THE FINAL FIX: We run the restart command in the background
      # using 'nohup ... &' to prevent a deadlock.
      ExecStart = ''
        /bin/sh -c "${pkgs.procps}/bin/pkill -9 -f '^${pkgs.hyprland}/bin/Hyprland' && nohup systemctl restart display-manager.service &"
      '';
    };
  };

  # This udev rule is CONFIRMED WORKING. Do not change it.
  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="kill-hyprland-on-undock.service"
  '';
}
