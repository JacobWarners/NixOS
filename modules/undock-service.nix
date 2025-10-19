{ config, pkgs, ... }:
{
  # -- eGPU Hot-Unplug Recovery (Future-Proof) --

  services.openssh.enable = true;

  systemd.services.kill-hyprland-on-undock = {
    description = "Forcefully terminate Hyprland session for eGPU undock recovery.";
    serviceConfig = {
      Type = "oneshot";
      # THE FINAL FIX: We use a Nix expression to get the correct path at build time.
      # This makes the command robust against updates.
      ExecStart = ''
        ${pkgs.procps}/bin/pkill -9 -f "^${pkgs.hyprland}/bin/Hyprland"
      '';
    };
  };

  # This udev rule is CONFIRMED WORKING. Do not change it.
  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="kill-hyprland-on-undock.service"
  '';
}
