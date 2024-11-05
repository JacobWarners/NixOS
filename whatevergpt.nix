{ config, pkgs, ... }:

{
  # Enable X11
  services.xserver.enable = true;
  services.xserver.layout = "us";

  # Use a display manager and desktop environment
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Specify the NVIDIA driver
  services.xserver.videoDrivers = [ "nvidia" ];

  # NVIDIA-specific settings
  hardware.nvidia = {
    open = false;  # Use closed-source (proprietary) driver
    modesetting.enable = true;
    nvidiaPersistenced = true;
    prime = {
      sync.enable = true;
      nvidiaBusId = "PCI:130:0:0";  # Replace with your NVIDIA GPU BusID
      intelBusId = "PCI:0:2:0";     # Replace with your Intel GPU BusID
    };
  };

  # Ensure OpenGL support is enabled
  hardware.opengl.enable = true;

  # Add your user to the 'video' group
  users.users.jake.extraGroups = [ "video" ];

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}

