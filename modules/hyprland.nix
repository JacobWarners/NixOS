# modules/hyprland.nix
# This module is now only responsible for SYSTEM-LEVEL configuration.
# User-specific packages and config are handled by Home-Manager.
{ config, pkgs, ... }:

{
  # 1. Enable Hyprland Programs & Services
  # This makes the hyprland package and XWayland available to the system.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # 2. Display Manager Integration
  # This makes Hyprland appear as an option in your login screen (e.g., GDM, SDDM).
  services.displayManager.sessionPackages = with pkgs; [
    hyprland
  ];

  # Creates the .desktop file needed for the session.
  environment.etc."xdg/wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=A dynamic tiling Wayland compositor
    Exec=Hyprland
    Type=Application
  '';

  # 3. Portal Configuration
  # This is a system-level service, so it belongs here. It allows Flatpaks
  # and other sandboxed apps to communicate with Hyprland.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # NOTE: User packages (rofi, waybar), fonts, and session variables have been
  # removed because they are correctly managed by your Home-Manager configuration.
}
