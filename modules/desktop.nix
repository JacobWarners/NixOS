{config, pkgs, ... }: 
{
  # Enable the X server if needed
  services.xserver = {
    enable = true;
};


  # Configure GDM and GNOME
  services.displayManager.gdm.enable = true;
  services.desktopManager.gnome.enable = true;

}

