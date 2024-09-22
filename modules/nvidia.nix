{ config, pkgs, ... }:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true;
    open = false;
    prime = {
      offload.enable = true;
      nvidiaBusId = "PCI:130:0:0";   # Replace with your NVIDIA GPU Bus ID
      intelBusId = "PCI:0:2:0";    # Replace with your Intel GPU Bus ID
    };
  };
  hardware.graphics.enable = true;
  hardware.nvidia.package = pkgs.linuxPackages.nvidiaPackages.stable;

  # Enable OpenGL support
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ pkgs.nvidiaPackages.stable ];
  };

  # Blacklist the nouveau driver
  boot.blacklistedKernelModules = [ "nouveau" ];

  # Ensure the NVIDIA kernel modules are included
  boot.extraModulePackages = with config.boot.kernelPackages; [ nvidia_x11 ];

  # (Optional) Disable modesetting for nouveau driver
  boot.kernelParams = [ "modprobe.blacklist=nouveau" ];

}

