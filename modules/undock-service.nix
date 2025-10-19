{ config, pkgs, ... }:
{
  services.openssh.enable = true;

  systemd.services.kill-hyprland-on-undock = {
    description = "Forcefully terminate Hyprland and restart the display manager.";
    path = [ pkgs.systemd ];
    serviceConfig = {
      Type = "oneshot";
      ExecStart = ''
        /bin/sh -c "${pkgs.procps}/bin/pkill -9 -f '^${pkgs.hyprland}/bin/Hyprland' && systemctl restart display-manager.service"
      '';
    };
  };

  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="kill-hyprland-on-undock.service"
  '';
}
