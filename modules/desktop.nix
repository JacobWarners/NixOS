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
services.xserver.config = pkgs.lib.mkMerge [

{
  Device = {
    Identifier = "NVIDIA Card";
    Driver = "nvidia";
    BusID = "PCI:130:0:0";  # Ensure this matches your NVIDIA GPU Bus-ID from `nvidia-smi`
    Optionn = [
      "AllowExternalGpus"
      "PrimaryGPU"
];
  };
  Screen = {
    Device = "NVIDIA Card";
    Monitor = "Monitor0";
  };
}
];

#environment.etc."X11/xorg.conf.d/90-nvidia.conf".text = ''
#    Section "Device"
#     Identifier "Device0"
#     Driver "nvidia"
#     BusID "PCI:130:0:0"
#     Option "AllowEmptyInitialConfiguration"
#     Option "AllowExternalGpus"
#   EndSection
# '';



  # Configure GDM and GNOME
}

#    Section "Device"
#      Identifier "Intel Graphics"
#      Driver "modesetting"
#      BusID "PCI:0:2:0"
#      Option "AccelMethod" "glamor"
#    EndSection


