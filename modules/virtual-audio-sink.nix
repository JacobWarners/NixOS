# File: virtual-audio-sink.nix
# This file defines a systemd user service to create a persistent virtual audio sink.

{ config, pkgs, ... }:

let
  # This creates a self-contained shell script in the Nix store.
  createSinkScript = pkgs.writeShellScriptBin "create-error-sounds-sink" ''
    #!${pkgs.bash}/bin/bash

    # Wait for the PipeWire socket to appear before proceeding.
    # The $XDG_RUNTIME_DIR variable is provided by the systemd service definition below.
    while [ ! -S "$XDG_RUNTIME_DIR/pulse/native" ]; do
      sleep 0.1
    done

    # Load the null-sink module. We wrap this in a loop to make it more
    # resilient against race conditions where the socket exists but the
    # server isn't ready for commands yet.
    until ${pkgs.pipewire}/bin/pactl load-module module-null-sink sink_name=error_sounds sink_properties=device.description=ErrorSounds; do
      echo "Waiting for pipewire-pulse to be ready..."
      sleep 1
    done

    # Load the loopback module to route the virtual sink's output to your default speakers.
    ${pkgs.pipewire}/bin/pactl load-module module-loopback source=error_sounds.monitor
  '';

in
{
  # This defines the systemd service that will run for your user account.
  systemd.user.services.create-error-sounds-sink = {
    description = "Create a virtual sink for error sounds";
    
    # Standard service dependencies for a graphical session user service.
    wantedBy = [ "graphical-session.target" ];
    after = [ "pipewire-pulse.service" ];
    requires = [ "pipewire-pulse.service" ];

    # This provides a PATH to the script's environment, which is crucial.
    # It ensures commands like `sleep` and `[` can be found.
    path = [
      pkgs.coreutils
      pkgs.pipewire
    ];

    # This block configures the service's execution environment.
    serviceConfig = {
      # Reliably sets the XDG_RUNTIME_DIR environment variable for the script.
      Environment = "XDG_RUNTIME_DIR=%t/user/%U";
      
      # THE CRITICAL FIX:
      # We explicitly tell systemd to use bash to run our script.
      # This avoids any potential issues with systemd not being able to
      # interpret the shebang line, which is the most likely cause of the
      # persistent "command not found" (exit 127) error.
      ExecStart = "${pkgs.bash}/bin/bash ${createSinkScript}/bin/create-error-sounds-sink";
      
      # Add robustness by making the service restart if it fails.
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
