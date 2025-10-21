# File: virtual-audio-sink.nix

{ config, pkgs, ... }:

let
  # The script itself is correct. The problem is the environment it runs in.
  createSinkScript = pkgs.writeShellScriptBin "create-error-sounds-sink" ''
    #!${pkgs.bash}/bin/bash

    # This loop is correct. It will succeed once pactl can connect.
    until ${pkgs.pipewire}/bin/pactl info >/dev/null 2>&1; do
      sleep 0.5
    done
    
    # Load the modules now that we know the server is ready.
    ${pkgs.pipewire}/bin/pactl load-module module-null-sink sink_name=error_sounds sink_properties=device.description=ErrorSounds
    ${pkgs.pipewire}/bin/pactl load-module module-loopback source=error_sounds.monitor
  '';

in
{
  systemd.user.services.create-error-sounds-sink = {
    description = "Create a virtual sink for error sounds";
    
    wantedBy = [ "graphical-session.target" ];
    after = [ "pipewire-pulse.service" "dbus.service" ]; # Add dbus dependency
    requires = [ "pipewire-pulse.service" ];

    path = [ pkgs.coreutils pkgs.pipewire ];

    serviceConfig = {
      # THE CRITICAL FIX:
      # We provide the service with the environment variables it needs to find and
      # communicate with the PipeWire/PulseAudio server.

      # 1. Import the D-Bus address from the user's session environment.
      #    This is essential for service discovery.
      ImportEnvironment = [ "DBUS_SESSION_BUS_ADDRESS" ];

      # 2. Explicitly set all other relevant variables to remove any ambiguity.
      Environment = [
        "XDG_RUNTIME_DIR=%t/user/%U"
        "PULSE_SERVER=unix:%t/user/%U/pulse/native"
      ];
      
      ExecStart = "${pkgs.bash}/bin/bash ${createSinkScript}/bin/create-error-sounds-sink";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
