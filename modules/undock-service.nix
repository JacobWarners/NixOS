{ config, pkgs, ... }:
{

  systemd.services.recover-on-undock = {
    description = "Kill Hyprland and restart the session manager on eGPU undock.";
    path = [ pkgs.systemd pkgs.procps ];
    serviceConfig = {
      Type = "oneshot";
      # THE FINAL ATTEMPT:
      # 1. Kill the frozen Hyprland session.
      # 2. Restart systemd-logind, the service that is actually stuck.
      ExecStart = ''
        /bin/sh -c "pkill -9 -f '^${pkgs.hyprland}/bin/Hyprland' && systemctl restart systemd-logind.service"
      '';
    };
  };

  # This udev rule is CONFIRMED WORKING. Do not change it.
  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="recover-on-undock.service"
  '';
}
