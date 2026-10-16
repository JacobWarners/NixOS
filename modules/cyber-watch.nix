{ pkgs, ... }:
{
  # [cyber] safeguard-trip watcher — rings htb-ping fail when a trip is logged in the HTB
  # transcripts. Declarative replacement for the old imperative ~/.config/systemd/user unit.
  # ExecStart points at the work-repo script (edit it + `systemctl --user restart cyber-watch`,
  # no rebuild needed); `path` provides the whole chain purely.
  systemd.user.services.cyber-watch = {
    description = "HTB [cyber] safeguard-trip watcher — rings htb-ping fail on a new trip";
    wantedBy = [ "default.target" ];
    after = [ "default.target" ];
    path = [ pkgs.bash pkgs.coreutils pkgs.gnugreppkgs.gnused pkgs.util-linux pkgs.ffmpeg ];
    serviceConfig = {
      ExecStart = "/home/jake/home-ai/work/htb/cyber-watch";
      Restart = "always";
      RestartSec = "5s";
    };
  };
}
