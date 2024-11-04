{config, pkgs, ... }: 
{
  # Enable the X server if needed
  services.xserver = {
  displayManager.gdm.enable = true;
  desktopManager.gnome.enable = true;
  displayManager.gdm.wayland = false;

   enable = true;
};


  # Configure GDM and GNOME
}

