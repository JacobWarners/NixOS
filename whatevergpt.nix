{ config, pkgs, ... }:

{
  # Enable X11
  services.xserver.enable = true;

  # Use a simple display manager and desktop environment
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Specify the NVIDIA driver
  services.xserver.videoDrivers = [ "nvidia" ];

  # NVIDIA-specific settings
  hardware.nvidia = {
    open = true;  # Use open-source kernel modules
    modesetting.enable = true;
    nvidiaPersistenced = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Ensure OpenGL support is enabled
  hardware.opengl.enable = true;

  # Add your user to the 'video' group
  users.users.jake.extraGroups = [ "video" ];
}

