{ config, pkgs, ... }:

{
  boot = {
    blacklistedKernelModules = [ "nouveau" "nvidia_drm" 'nvidia_modeset" "nvidia" ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    boot.extraModulePackages = [ pkgs.linuxPackages.nvidia_x11];
    packages = [ pkgs.linuxPackages.nvidia_x11 ];


    initrd.luks.devices."luks-6cb1713b-252a-435f-8c5c-d4b404e9db96" = {
      device = "/dev/disk/by-uuid/6cb1713b-252a-435f-8c5c-d4b404e9db96";
    };
#    kernelParams = [ 
#      "nvidia-drm.modeset=1"
#      "modprobe.blacklist=nouveau"
#];
      # Blacklist nouveau driver
#  };
};
}
