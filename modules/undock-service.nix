# /etc/nixos/configuration.nix

{ config, pkgs, ... }:

{
# 1. Systemd service to KILL the Hyprland process directly.
#    This is much faster than restarting the display-manager.
systemd.services.egpu-undock-recover = {
  description = "Kill Hyprland session after eGPU is unplugged.";
  serviceConfig = {
    Type = "oneshot";
    # The CHANGE is here: We now use pkill to terminate Hyprland.
    ExecStart = "${pkgs.procps}/bin/pkill Hyprland";
  };
};

# 2. The Udev rule remains UNCHANGED.
services.udev.extraRules = ''
  ACTION=="remove", SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x73ff", TAG+="systemd", ENV{SYSTEMD_WANTS}+="egpu-undock-recover.service"
'';
}
