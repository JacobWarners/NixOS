{ config, pkgs, ... }:

{
  systemd.user.services.create-error-sounds-sink = {
    description = "Create a virtual sink for error sounds";

    # This ties the service directly to the lifecycle of PipeWire's PulseAudio server.
    partOf = [ "pipewire-pulse.service" ];
    after = [ "pipewire-pulse.service" ];
    wantedBy = [ "pipewire-pulse.service" ];

    serviceConfig = {
      Type = "oneshot";
      # This creates a self-contained script with a proper PATH and environment.
      ExecStart = let
        script = pkgs.writeShellApplication {
          name = "create-sink-script";
          # This provides `pactl`, `sleep`, etc., inside the script.
          runtimeInputs = with pkgs; [ coreutils pipewire ];
          text = ''
            # This is the critical variable that tells pactl where to find the audio server.
            # The %U is automatically replaced by systemd with your user ID.
            export PULSE_SERVER="unix:/run/user/%U/pulse/native"

            # Wait for the audio server's socket to exist before continuing.
            # This prevents race conditions during login.
            while [ ! -S "$XDG_RUNTIME_DIR/pulse/native" ]; do
              sleep 0.1
            done

            # Load the modules.
            pactl load-module module-null-sink sink_name=error_sounds
            pactl load-module module-loopback source=error_sounds.monitor
          '';
        };
      in "${script}/bin/create-sink-script";
    };
  };
}
