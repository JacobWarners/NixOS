# In your NixOS configuration (e.g., configuration.nix or home.nix)

systemd.user.services.key-counter-daemon = {
  # A short description for the service
  description = "A daemon that counts keystrokes and manages game states for Waybar.";

  # This ensures the service starts when you log into a graphical session.
  wantedBy = [ "graphical-session.target" ];

  # This defines the actual service behavior.
  serviceConfig = {
    # --- IMPORTANT ---
    # Replace this with the full, absolute path to your compiled Rust binary.
    ExecStart = "/home/jake/Documents/Code/sonic/key_counter_daemon/target/release/key_counter_daemon --normal";

    # This makes systemd automatically restart the service if it ever stops.
    Restart = "always";

    # Wait 1 second before restarting.
    RestartSec = "1s";
  };
};

