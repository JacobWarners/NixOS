{ pkgs, ... }:

{
  systemd.user.services.sonic-waygame = {
    description = "Sonic Waygame Health Daemon";
    
    # "After" ensures it starts after the graphical session is ready
    after = [ "graphical-session.target" ];
    
    # "wantedBy" replaces the [Install] section
    wantedBy = [ "graphical-session.target" ];

    # "serviceConfig" replaces the [Service] section
    serviceConfig = {
      ExecStart = "/home/jake/Documents/Code/Rust/key_counter_daemon/target/release/key_counter_daemon --normal";
      
      # Ensure libnotify (notify-send) and hyprland (hyprctl) are in the path
      Environment = "PATH=${pkgs.libnotify}/bin:${pkgs.hyprland}/bin:/run/current-system/sw/bin:/usr/bin";
      
      Restart = "always";
      RestartSec = "5";
    };
  };
}
