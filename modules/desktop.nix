{config, pkgs, ... }: 
{
  # Enable the X server if needed
  services.xserver = {
  displayManager.gdm.enable = true;
  desktopManager.gnome.enable = true;
#  displayManager.gdm.wayland = false;
#  displayManager.sddm.enable = true;

   enable = true;
};

environment.etc."X11/xorg.conf.d/90-nvidia.conf".text = ''
    Section "Device"
     Identifier "Device0"
     Driver "nvidia"
     BusID "PCI:130:0:0"
     Option "AllowEmptyInitialConfiguration" "true"
     Option "AllowExternalGpus" "true"
     Option "PrimaryGPU" "true"
   EndSection

    Section "Screen"
    Identifier "Screen0"
    Device "Device0" 
    Monitor = "Monitor0"
  EndSection
 '';



  # Configure GDM and GNOME
}

#    Section "Device"
#      Identifier "Intel Graphics"
#      Driver "modesetting"
#      BusID "PCI:0:2:0"
#      Option "AccelMethod" "glamor"
#    EndSection


