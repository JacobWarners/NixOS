# /etc/nixos/configuration.nix

{ config, pkgs, ... }:
let
  egpu-undock-script = pkgs.writeShellScriptBin "egpu-undock-script" ''
    #! ${pkgs.bash}/bin/bash
    
    # Function to log messages to the system journal
    log() {
      echo "$1" | ${pkgs.systemd}/bin/systemd-cat -p info -t egpu-undock
    }

    log "eGPU undock detected. Firing refined recovery script."

    # --- Find the Active Hyprland User (More Robust Method) ---
    # Find the Hyprland process and get its owner's user ID.
    USER_ID=$(pgrep -a Hyprland | head -n 1 | awk '{print $1}' | xargs -r ps -o uid= -p)
    
    if [ -z "$USER_ID" ]; then
      log "Error: Could not find the User ID of the Hyprland process. Aborting."
      exit 1
    fi

    USER_NAME=$(id -un $USER_ID)
    log "Found active graphical user: $USER_NAME (UID: $USER_ID)"

    # --- Find the Hyprland Session ---
    export XDG_RUNTIME_DIR="/run/user/$USER_ID"
    export HYPRLAND_INSTANCE_SIGNATURE=$(ls -t $XDG_RUNTIME_DIR/hypr/ 2>/dev/null | head -n 1)

    if [ -z "$HYPRLAND_INSTANCE_SIGNATURE" ]; then
      log "Error: Could not find HYPRLAND_INSTANCE_SIGNATURE. Attempting fallback pkill..."
      ${pkgs.procps}/bin/pkill -9 -f ".Hyprland-wrapped"
      exit 1
    fi

    log "Found Hyprland Signature: $HYPRLAND_INSTANCE_SIGNATURE"

    # --- Execute Recovery ---
    log "Attempting graceful exit with hyprctl..."
    # Run hyprctl as the correct user with the correct environment
    sudo -u $USER_NAME ${pkgs.hyprland}/bin/hyprctl dispatch exit

    sleep 2

    # Check if it's still running and use the hammer if needed
    if pgrep -f ".Hyprland-wrapped" > /dev/null; then
      log "Hyprland did not exit gracefully. Sending SIGKILL..."
      ${pkgs.procps}/bin/pkill -9 -f ".Hyprland-wrapped"
    fi

    log "Recovery sequence complete."
  '';

in
{
  # -- eGPU Hot-Unplug Recovery (Refined User-Finding) --

  systemd.services.egpu-undock-recover = {
    description = "Run eGPU undock recovery script for Hyprland.";
    serviceConfig = {
      Type = "oneshot";
      ExecStart = "${egpu-undock-script}/bin/egpu-undock-script";
    };
  };

  # This udev rule is CONFIRMED WORKING. Do not change it.
  services.udev.extraRules = ''
    ACTION=="unbind", DEVPATH=="/devices/pci0000:00/0000:00:01.2/0000:60:00.0/0000:61:04.0", TAG+="systemd", ENV{SYSTEMD_WANTS}+="egpu-undock-recover.service"
  '';
}
