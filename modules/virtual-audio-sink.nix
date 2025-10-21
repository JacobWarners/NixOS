{ config, pkgs, ... }:

let
  # Create a self-contained script that behaves like a real command-line program.
  # This is the correct, robust way to solve the "command not found" error.
  createSinkScript = pkgs.writeShellScriptBin "create-error-sounds-sink" ''
    #!${pkgs.bash}/bin/bash

    # This is the critical variable that tells pactl where to find the audio server.
    export PULSE_SERVER="unix:/run/user/$(id -u)/pulse/native"

    # Wait up to 5 seconds for the audio server's socket to appear before failing.
    # This prevents the script from failing during a slow startup.
    for i in $(seq 1 50); do
      if [ -S "$XDG_RUNTIME_DIR/pulse/native" ]; then
        break
      fi
      sleep 0.1
    done

    # If the socket never appeared, exit gracefully.
    if [ ! -S "$XDG_RUNTIME_DIR/pulse/native" ]; then
      echo "PipeWire PulseAudio socket not found, exiting."
      exit 0
    fi

    # Load the modules to create the virtual sink and loop it back to the default output.
    ${pkgs.pipewire}/bin/pactl load-module module-null-sink sink_name=error_sounds
    ${pkgs.pipewire}/bin/pactl load-module module-loopback source=error_sounds.monitor
  '';

in
{
  # Define the systemd service to run the script.
  systemd.user.services.create-error-sounds-sink = {
    description = "Create a virtual sink for error sounds";

    # This ensures the service starts automatically when you log in.
    wantedBy = [ "graphical-session.target" ];
    after = [ "pipewire-pulse.service" ];

    # The service simply runs the script we created above.
    serviceConfig.ExecStart = "${createSinkScript}/bin/create-error-sounds-sink";
  };
}
