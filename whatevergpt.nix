{ config, pkgs, ... }:

{
  # Enable X11
  services.xserver.enable = true;

  # Use a display manager and desktop environment
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Specify the video drivers
  services.xserver.videoDrivers = [ "modesetting" ];

  # Enable PRIME Offloading
  hardware.nvidia = {
    open = true;  # Use open-source kernel modules
    modesetting.enable = true;
    prime = {
      offload.enable = true;
      nvidiaBusId = "PCI:130:0:0";  # Replace with your NVIDIA GPU BusID
      intelBusId = "PCI:0:2:0";     # Replace with your Intel GPU BusID
    };
  };

  # Other configurations...
  nixpkgs.config.allowUnfree = true;


  # Ensure OpenGL support is enabled
  hardware.opengl.enable = true;

  # Add your user to the 'video' group
  users.users.jake.extraGroups = [ "video" ];
}

