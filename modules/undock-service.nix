{ config, pkgs, ... }:

{
  # -- eGPU Hot-Unplug Recovery --

  # 1. Systemd service to restart the display manager upon trigger.
  systemd.services.egpu-undock-recover = {
    description = "Restart Display Manager after eGPU is unplugged.";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${pkgs.systemd}/bin/systemctl restart display-manager.service";
    };
  };

  # 2. Udev rule to detect your specific Radeon eGPU's removal.
  services.udev.extraRules = ''
    # Trigger on removal of the AMD Radeon RX 6600 series eGPU.
    ACTION=="remove", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x73ff", TAG+="systemd", ENV{SYSTEMD_WANTS}+="egpu-undock-recover.service"
  '';

}
