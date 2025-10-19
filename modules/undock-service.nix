# /etc/nixos/configuration.nix

{ config, pkgs, ... }:
let
  # The forceful recovery script.
  egpu-undock-script = pkgs.writeShellScriptBin "egpu-undock-script" ''
    #! ${pkgs.bash}/bin/bash
    
    log() {
      echo "$1" | ${pkgs.systemd}/bin/systemd-cat -p info -t egpu-undock
    }

    log "eGPU undock detected (Bridge DEVPATH unbind). Firing recovery script."

    # Go straight for the hammer. The session is already doomed.
    ${pkgs.procps}/bin/pkill -9 -f ".Hyprland-wrapped"

    log "Recovery sequence complete."
  '';

in
{
  # -- eGPU Hot-Unplug Recovery (Final Version) --

  systemd.services.egpu-undock-recover = {
    description = "Run eGPU undock recovery script for Hyprland.";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${egpu-undock-script}/bin/egpu-undock-script";
    };
  };

  services.udev.extraRules = ''
    # THIS IS THE FINAL RULE:
    # Target the 'unbind' action on the exact DEVPATH of the parent Thunderbolt PCI bridge.
    # This is immune to the attribute race condition.
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="egpu-undock-recover.service"
  '';
}
