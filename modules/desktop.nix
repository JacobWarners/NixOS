{ config, pkgs, ... }:

{
  # 1. Basic X Server Setup
  # This remains the same to enable the graphical environment.
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
  };

  # 2. Configure LightDM with Auto-Login 🚀
  services.displayManager.ly = {
    enable = true;
    # Auto-login the specified user.
    # Set a timeout for auto-login, or set to 0 to log in immediately.
  };
}
