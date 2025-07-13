# ./modules/hyprland.nix

{ config, pkgs, ... }:

{
  # Enable Hyprland
  programs.hyprland = {
    enable = true;
    # Recommended for running X11 apps in Wayland
    xwayland.enable = true; 
  };

  # If you want to use GDM (your current display manager) to launch Hyprland,
  # you don't need to change anything else here. GDM will automatically
  # detect the Hyprland session. Just select "Hyprland" from the gear
  # icon on the login screen.
  
  # Note: Your existing desktop.nix enables GDM and GNOME. This is fine.
  # The two can coexist. You simply choose which session to start at login.
}
