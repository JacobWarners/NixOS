{ pkgs, ... }:

{
  systemd.user.services.sonic-waygame = {
    Unit = {
      Description = "Sonic Waygame Health Daemon";
      After = [ "graphical-session.target" ];
    };

    Service = {
      # Points to your manually compiled binary
      ExecStart = "/home/jake/Documents/Code/sonic-waygame/key_counter_daemon/target/release/key_counter_daemon --normal";
      
      # IMPORTANT: We add libnotify (for notify-send) and hyprland (for hyprctl) to the PATH
      # This ensures the Rust app can actually run those commands.
      Environment = "PATH=${pkgs.libnotify}/bin:${pkgs.hyprland}/bin:/run/current-system/sw/bin:/usr/bin";
      
      Restart = "always";
      RestartSec = "5";
    };

    Install = {
      WantedBy = [ "graphical-session.target" ];
    };
  };
}
