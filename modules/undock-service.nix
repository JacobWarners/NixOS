# /etc/nixos/configuration.nix

{ config, pkgs, ... }:
let
  egpu-undock-script = pkgs.writeShellScriptBin "egpu-undock-script" ''
    #! ${pkgs.bash}/bin/bash
    
    log() {
      echo "$1" | ${pkgs.systemd}/bin/systemd-cat -p info -t egpu-undock
    }

    log "eGPU undock detected (DEVPATH match). Starting recovery sequence."

    log "Attempting forceful pkill (SIGKILL) immediately."
    # We go straight for the hammer, as we know the session will not respond gracefully.
    ${pkgs.procps}/bin/pkill -9 -f ".Hyprland-wrapped"

    log "Recovery sequence complete."
  '';

in
{
  # ... your other NixOS configuration options

  # -- eGPU Hot-Unplug Recovery (DEVPATH Version) --

  systemd.services.egpu-undock-recover = {
    description = "Run eGPU undock recovery script for Hyprland.";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${egpu-undock-script}/bin/egpu-undock-script";
    };
  };

  services.udev.extraRules = ''
    # THIS IS THE FINAL RULE:
    # Trigger on the REMOVE action for the GPU's exact DEVPATH.
    ACTION=="remove", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:01.0/0000:62:00.0/0000:63:00.0/0000:64:00.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="egpu-undock-recover.service"
  '';

}
