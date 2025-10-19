# /etc/nixos/configuration.nix

{ config, pkgs, ... }:
let
  egpu-undock-script = pkgs.writeShellScriptBin "egpu-undock-script" ''
    #! ${pkgs.bash}/bin/bash
    
    log() {
      echo "$1" | ${pkgs.systemd}/bin/systemd-cat -p info -t egpu-undock
    }

    log "eGPU undock detected (PCI Bridge). Starting recovery sequence."

    HYPRLAND_USER=$(pgrep -u $(logname) Hyprland | head -n 1 | xargs -r ps -o user= -p)

    if [ -z "$HYPRLAND_USER" ]; then
      log "Could not find a running Hyprland process. Exiting."
      exit 0
    fi

    log "Found Hyprland session for user: $HYPRLAND_USER"

    log "Attempting forceful pkill (SIGKILL) immediately."
    # We go straight for the hammer now, as we know the session will not respond gracefully.
    ${pkgs.procps}/bin/pkill -9 -f ".Hyprland-wrapped"

    log "Recovery sequence complete."
  '';

in
{
  # ... your other NixOS configuration options

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
    # Target the REMOVE action on the Thunderbolt PCI BRIDGE, not the GPU itself.
    ACTION=="remove", SUBSYSTEM=="pci", ATTR{vendor}=="0x8086", ATTR{device}=="0x15d3", TAG+="systemd", ENV{SYSTEMD_WANTS}+="egpu-undock-recover.service"
  '';
}
