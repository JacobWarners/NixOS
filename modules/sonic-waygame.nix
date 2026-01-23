systemd.user.services.sonic-waygame = {
  Unit = {
    Description = "Sonic Waygame Health Daemon";
    After = [ "graphical-session.target" ];
  };

  Service = {
    # 1. Update the path to your compiled binary
    ExecStart = "/home/jake/Documents/Code/sonic-waygame/key_counter_daemon/target/release/key_counter_daemon --normal";
    
    # 2. CRITICAL: Add libnotify and hyprland to the PATH so the Rust app can find them
    # If you are using Home Manager, you can usually use:
    # Environment = "PATH=${pkgs.libnotify}/bin:${pkgs.hyprland}/bin:/run/current-system/sw/bin:/usr/bin";
    
    # If you are editing a raw nix file and can't use 'pkgs', try explicitly setting the path:
    Environment = "PATH=/run/current-system/sw/bin:/usr/bin";
    
    Restart = "always";
    RestartSec = "5";
  };

  Install = {
    WantedBy = [ "graphical-session.target" ];
  };
};
