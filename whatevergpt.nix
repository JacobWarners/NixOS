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
    modesetting.enable = true;
    nvidiaPersistenced = true;
    # Use the stable NVIDIA driver package
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };

  # Ensure OpenGL support is enabled
  hardware.opengl.enable = true;

  # Optional: Add your user to the 'video' group
  users.users.jake.extraGroups = [ "video" ];
}

