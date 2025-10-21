{ config, pkgs, ... }:

{
  # This creates a systemd service that runs for your user account.
  systemd.user.services.create-error-sounds-sink = {
    description = "Create a virtual sink for error sounds";

    # This ensures the service only starts after PipeWire is ready.
    after = [ "pipewire-pulse.socket" ];
    wants = [ "pipewire-pulse.socket" ];

    # This tells the service what to do.
    serviceConfig = {
      Type = "oneshot";
      # We use a short script to ensure the commands run correctly.
      ExecStart = let
        script = pkgs.writeShellScript "create-sink.sh" ''
          # Wait a second for the audio server to be fully initialized.
          /run/current-system/sw/bin/sleep 1
          # Run the commands to create and link the virtual sink.
          ${pkgs.pipewire}/bin/pactl load-module module-null-sink sink_name=error_sounds
          ${pkgs.pipewire}/bin/pactl load-module module-loopback source=error_sounds.monitor
        '';
      in "${script}";
    };

    # This makes the service start automatically when you log in.
    wantedBy = [ "default.target" ];
  };
}
