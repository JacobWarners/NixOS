{ config, pkgs, ... }:

{
  services.xserver.enable = true;
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Enable Wayland support
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.wayland = true;

  # Enable Hyprland
  services.xserver.windowManager.hyprland = {
    enable = true;
    wayland = true;
  };

  # Optionally allow selection between GNOME and Hyprland at login
  services.xserver.displayManager.sessionPackages = with pkgs; [
    gnome
    hyprland
  ];
}

