{ config, pkgs, ... }:

{



 environment.etc."X11/xorg.conf.d/11-nvidia.conf".text = ''
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
    Monitor "Monitor0"
 EndSection

   Section "Monitor"
   Identifier "Monitor0"
   Modeline "2560x1440_180.00"  735.75  2560 2760 3048 3536  1440 1443 1448 1530 -hsync +vsync
 EndSection
'';




########################################
  specialisation = {
    egpu.configuration = {
        system.nixos.tags = ["nvidia"];

        boot = {
          # Optionally blacklist the integrated graphics module
          blacklistedKernelModules = [ "i915" ];
          kernelParams = [ "module_blacklist=i915" ];
        };
  services.xserver.videoDrivers = ["nvidia"];
};
};

  hardware.nvidia = {

   # Modesetting is required.
   modesetting.enable = true;
    open = false;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
#    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
    nvidiaPersistenced = true;

};




}



