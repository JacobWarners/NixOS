{ config, pkgs, ... }:
{
  systemd.services.recover-on-undock = {
    description = "Recover from eGPU undock by switching to a TTY.";
    # We need pkill (procps) and chvt (kbd)
    path = [ pkgs.procps pkgs.kbd pkgs.coreutils ];
    serviceConfig = {
      Type = "oneshot";
      # THE SIDESTEP STRATEGY:
      # 1. Kill the frozen Hyprland graphical session.
      # 2. Pause briefly to let the system process the kill signal.
      # 3. Force the kernel to switch to a non-graphical text console (TTY2).
      #    This bypasses the deadlocked systemd-logind.
      ExecStart = ''
        /bin/sh -c "${pkgs.procps}/bin/pkill -9 -f '^${pkgs.hyprland}/bin/Hyprland' && sleep 1 && ${pkgs.kbd}/bin/chvt 2"
      '';
    };
  };

  # This udev rule is CONFIRMED WORKING. Do not change it.
  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="recover-on-undock.service"
  '';
}
