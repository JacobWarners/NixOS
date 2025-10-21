# File: virtual-audio-sink.nix
# This file defines a systemd user service to create a persistent virtual audio sink.

{ config, pkgs, ... }:

let
  createSinkScript = pkgs.writeShellScriptBin "create-error-sounds-sink" ''
    #!${pkgs.bash}/bin/bash

    # THE NEW, MORE ROBUST WAIT LOGIC:
    # Instead of checking for a file, we wait until we can successfully connect to the
    # PulseAudio server. This is a much more reliable indicator that it's ready.
    until ${pkgs.pipewire}/bin/pactl info >/dev/null 2>&1; do
      sleep 0.5
    done

    # Once the loop above exits, the server is guaranteed to be ready.
    # Now we can load our modules without any further checks.

    # Load the null-sink module.
    ${pkgs.pipewire}/bin/pactl load-module module-null-sink sink_name=error_sounds sink_properties=device.description=ErrorSounds
    
    # Load the loopback module to route the virtual sink's output to your default speakers.
    ${pkgs.pipewire}/bin/pactl load-module module-loopback source=error_sounds.monitor
  '';

in
{
  systemd.user.services.create-error-sounds-sink = {
    description = "Create a virtual sink for error sounds";
    
    wantedBy = [ "graphical-session.target" ];
    after = [ "pipewire-pulse.service" ];
    requires = [ "pipewire-pulse.service" ];

    path = [
      pkgs.coreutils
      pkgs.pipewire
    ];

    serviceConfig = {
      Environment = "XDG_RUNTIME_DIR=%t/user/%U";
      ExecStart = "${pkgs.bash}/bin/bash ${createSinkScript}/bin/create-error-sounds-sink";
      Restart = "on-failure";
      RestartSec = 5;
    };
  };
}
