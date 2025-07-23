{ config, pkgs, ... }:

{
  systemd.user.services.sonic-waygame = {

    # A short description for the service
    description = "A daemon that counts keystrokes and manages game states for Waybar.";

    # This ensures the service starts when your user session starts.
    wantedBy = [ "default.target" ];

    # --- Updated options to wait for the audio system ---
    # This tells systemd to start our service after the audio server is ready.
    # If you use PulseAudio instead of PipeWire, change this to "pulseaudio.service".
    after = [ "graphical-session.target" "pipewire.service" ];
    wants = [ "pipewire.service" ];

    # This defines the actual service behavior.
    serviceConfig = {
      # --- New: Add a short delay for extra stability ---
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 2";

      # --- IMPORTANT ---
      # Replace this with the full, absolute path to your compiled Rust binary.
      ExecStart = "/home/jake/Documents/Code/sonic-waygame/key_counter_daemon/target/release/key_counter_daemon --normal";


      # This makes systemd automatically restart the service if it ever stops.
      Restart = "always";

      # Wait 1 second before restarting.
      RestartSec = "1s";
      
      # This will give us a full backtrace if the Rust program crashes.
      Environment = "RUST_BACKTRACE=1";
    };
  };
}
