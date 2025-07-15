{ config, pkgs, ... }:
{
  # Enable the X server if needed
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
    #  displayManager.startx.enable = true;
    #  displayManager.gdm.wayland = false;
    enable = true;
  };
  systemd.services.gdm = {
    serviceConfig.ExecStartPre = [ "/bin/sleep 3" ];
  };

}
