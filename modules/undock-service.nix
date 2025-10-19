# /etc/nixos/configuration.nix

{ config, pkgs, ... }:
let
  # 1. Define our robust recovery script.
  #    This gives us a multi-step process with logging.
  egpu-undock-script = pkgs.writeShellScriptBin "egpu-undock-script" ''
    #! ${pkgs.bash}/bin/bash
    
    # Function to log messages to the system journal
    log() {
      echo "$1" | ${pkgs.systemd}/bin/systemd-cat -p info -t egpu-undock
    }

    log "eGPU undock detected. Starting recovery sequence."

    # Find the user running the Hyprland session
    HYPRLAND_USER=$(pgrep -u $(logname) Hyprland | head -n 1 | xargs -r ps -o user= -p)

    if [ -z "$HYPRLAND_USER" ]; then
      log "Could not find a running Hyprland process. Exiting."
      exit 0
    fi

    log "Found Hyprland session for user: $HYPRLAND_USER"

    # Step 1: Try a graceful exit via hyprctl (may not work on a frozen session)
    log "Attempting graceful exit with hyprctl..."
    # We need to run this as the user to connect to their session
    sudo -u $HYPRLAND_USER DISPLAY=:0 ${pkgs.hyprland}/bin/hyprctl dispatch exit

    sleep 2 # Give it a moment to exit

    # Step 2: If it's still running, use a standard pkill (SIGTERM)
    if pgrep -x ".Hyprland-wrapped" > /dev/null; then
      log "Hyprland still running. Sending SIGTERM with pkill..."
      ${pkgs.procps}/bin/pkill -f ".Hyprland-wrapped"
      sleep 2
    fi

    # Step 3: If it's STILL running, bring out the hammer (SIGKILL)
    if pgrep -x ".Hyprland-wrapped" > /dev/null; then
      log "Hyprland is stubborn. Sending SIGKILL..."
      ${pkgs.procps}/bin/pkill -9 -f ".Hyprland-wrapped"
    fi

    log "Recovery sequence complete."
  '';

in
{
  # ... your other NixOS configuration options

  # -- eGPU Hot-Unplug Recovery (Robust Version) --

  # 2. Create the systemd service to run our script.
  systemd.services.egpu-undock-recover = {
    description = "Run eGPU undock recovery script for Hyprland.";
    # This ensures the script runs after basic system services are up
    after = [ "systemd-user-sessions.service" ];
    serviceConfig = {
      Type = "oneshot";
      # Just execute the script we defined above
      ExecStart = "${egpu-undock-script}/bin/egpu-undock-script";
    };
  };

  # 3. The Udev rule that triggers the service (unchanged logic).
  services.udev.extraRules = ''
  # Temporary diagnostic rule to log all properties of the GPU event.
  # This will trigger on ANY change, bind, unbind, or remove event.
  SUBSYSTEM=="pci", ATTR{vendor}=="0x1002", ATTR{device}=="0x73ff", RUN+="/bin/sh -c 'echo --- EVENT --- >> /tmp/gpu_event.log; env >> /tmp/gpu_event.log'"
  '';


}
