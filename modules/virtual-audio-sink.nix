{ config, pkgs, ... }:

{
  systemd.user.services.create-error-sounds-sink = {
    description = "Create a virtual sink for error sounds";

    # More robust dependencies: wait for the actual services, not just the socket.
    after = [ "pipewire.service" "pipewire-pulse.service" ];
    wants = [ "pipewire.service" "pipewire-pulse.service" ];

    serviceConfig = {
      Type = "oneshot";
      # Using writeShellApplication is more robust for ExecStart
      ExecStart = let
        script = pkgs.writeShellApplication {
          name = "create-sink-script";
          runtimeInputs = with pkgs; [ pipewire ]; # Makes 'pactl' available in the script's PATH
          text = ''
            # Wait a moment for the audio server to be fully ready
            sleep 1
            # Create the sink and the loopback
            pactl load-module module-null-sink sink_name=error_sounds
            pactl load-module module-loopback source=error_sounds.monitor
          '';
        };
      in "${script}/bin/create-sink-script";
    };

    # A more reliable target for graphical user sessions
    wantedBy = [ "graphical-session.target" ];
  };
}
