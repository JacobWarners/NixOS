{ config, pkgs, ... }:

{
  # Enable X11
  services.xserver.enable = true;
  services.xserver.layout = "us";

  # Use a display manager and desktop environment
  services.xserver.displayManager.sddm.enable = true;
  services.xserver.desktopManager.plasma5.enable = true;

  # Use modesetting driver for Intel GPU
  services.xserver.videoDrivers = [ "modesetting" ];

  # NVIDIA-specific settings
  hardware.nvidia = {
    open = false;  # Use closed-source (proprietary) driver
    modesetting.enable = true;
    nvidiaPersistenced = true;
    prime = {
      offload.enable = true;
      sync.enable = true;
    };
  };

  # Ensure OpenGL support is enabled
  hardware.opengl.enable = true;

  # Add your user to the 'video' group
  users.users.jake.extraGroups = [ "video" ];

  # Custom Xorg Configuration
  services.xserver.config = ''
    Section "ServerLayout"
        Identifier     "layout"
        Screen      0  "intel"
        Option         "AllowNVIDIAGPUScreens"
    EndSection

    Section "Device"
        Identifier     "intel"
        Driver         "modesetting"
        BusID          "PCI:0:2:0"
        Option         "DRI" "3"
        Option         "AccelMethod" "glamor"
    EndSection

    Section "Screen"
        Identifier     "intel"
        Device         "intel"
    EndSection

    Section "Device"
        Identifier     "nvidia"
        Driver         "nvidia"
        BusID          "PCI:130:0:0"  # Replace with your NVIDIA GPU BusID
        Option         "AllowEmptyInitialConfiguration" "true"
    EndSection
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;
}

