{config, pkgs, ... }: 
{
  # Enable the X server if needed
  services.xserver = {
  displayManager.gdm.enable = false;
  desktopManager.gnome.enable = true;
#  displayManager.gdm.wayland = false;
  displayManager.sddm.enable = true;
#   deviceSection = ''
#     Section "Device"
#       Identifier "Intel Graphics"
#       Driver "modesetting"
#       BusID "PCI:0:2:0"
#       Option "AccelMethod" "glamor"
#     EndSection

#     Section "Device"
#       Identifier "Nvidia Graphics"
#       Driver "nvidia"
#       BusID "PCI:130:0:0"
#       Option "AllowEmptyInitialConfiguration"
#     EndSection
#   '';


   enable = true;
};


  # Configure GDM and GNOME
}

