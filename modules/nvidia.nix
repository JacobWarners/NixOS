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
  hardware.opengl.enable = true;
  hardware.nvidia.package = pkgs.linuxPackages.nvidiaPackages.stable;
}

