# File: virtual-audio-sink.nix
# This file uses the correct declarative NixOS option for older versions
# to configure the PipeWire-PulseAudio server directly.

{ config, pkgs, ... }:

{
  # This option targets the pipewire-pulse.conf file.
  services.pipewire.extraConfig."pipewire-pulse.conf" = {
    # The 'pulse.cmd' section instructs the server to execute
    # commands after it has successfully initialized. This avoids all
    # the timing and environment issues we fought with systemd.
    "pulse.cmd" = [
      { 
        cmd = "${pkgs.pipewire}/bin/pactl";
        args = "load-module module-null-sink sink_name=error_sounds sink_properties=device.description=ErrorSounds";
      }
      {
        cmd = "${pkgs.pipewire}/bin/pactl";
        args = "load-module module-loopback source=error_sounds.monitor";
      }
    ];
  };

  # We no longer need the systemd service. 
  # Ensure it is disabled to avoid any conflicts.
  systemd.user.services.create-error-sounds-sink.enable = false;
}
