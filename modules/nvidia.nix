## Boot config has kernel params and blacklisting nouveau

{config , pkgs, ...}:

{
  services.xserver.videoDrivers = [ "nvidia" ];
  services.xserver.deviceSection = ''
  Option "AllowEmptyInitialConfiguration" "true"
  Option "Modesetting" "true"
'';


  hardware.nvidia = {
    modesetting.enable = true;
    package = config.boot.kernelPackages.nvidiaPackages.latest;
    open = true;
    prime = {
      offload.enable = true;            # Enable offload mode
      offload.enableOffloadCmd = true;          # Provides the nvidia-offload command for easier offloading
      nvidiaBusId = "PCI:130:0:0";      # Replace with your NVIDIA GPU Bus ID
      intelBusId = "PCI:0:2:0";         # Replace with your Intel GPU Bus ID
    };
  };

  # Environment variables for NVIDIA
  environment.variables = {
    __GLX_VENDOR_LIBRARY_NAME = "nvidia";
    __GL_GSYNC_ALLOWED = "0"; # Optional: Disable G-SYNC if issues arise
    __GL_VRR_ALLOWED = "0";   # Optional: Disable Variable Refresh Rate
  };
  # Enable OpenGL support
  hardware.opengl = {
    enable = true;
    extraPackages = with pkgs; [ pkgs.linuxPackages.nvidiaPackages.stable ];
  };
}

