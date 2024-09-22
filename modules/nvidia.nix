## Boot config has kernel params and blacklisting nouveau

{config , pkgs, ...}:

{
  services.xserver.videoDrivers = [ "nvidia" ];

  hardware.nvidia = {
    modesetting.enable = true;
    open = true;
    prime = {
      offload.enable = true;            # Enable offload mode
      offload.enableOffloadCmd = true;          # Provides the nvidia-offload command for easier offloading
      nvidiaBusId = "PCI:130:0:0";      # Replace with your NVIDIA GPU Bus ID
      intelBusId = "PCI:0:2:0";         # Replace with your Intel GPU Bus ID
    };
  };

  # Enable OpenGL support
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ pkgs.linuxPackages.nvidiaPackages.stable ];
  };
}

