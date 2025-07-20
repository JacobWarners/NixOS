{ config, pkgs, ... }:

{
  # 1. Basic X Server Setup
  # This remains the same to enable the graphical environment.
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
  };

  # 2. Configure LightDM with Auto-Login 🚀
  services.xserver.displayManager.sddm = {
    enable = true;
    theme = "sddm-astronaut";
    # Auto-login the specified user.
    # Set a timeout for auto-login, or set to 0 to log in immediately.
  };
  # 5. Disable greetd
  # This ensures your old display manager does not conflict with the new one.
  services.greetd.enable = false;
}
