{ config, pkgs, ... }:

{
  # 1. Basic X Server Setup
  services.xserver = {
    enable = true;
    videoDrivers = ["amdgpu"];
    # This ensures Hyprland is an available session for LightDM
  };

  # 2. Configure LightDM
  services.displayManager.ly = {
    enable = true;
};
}
