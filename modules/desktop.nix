{ config, pkgs, ... }:

{
  # Enable the X server if needed
  services.xserver.enable = true;

  # Configure GDM and GNOME
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.wayland = true;
  services.xserver.desktopManager.gnome.enable = true;

  # Create a session file for Hyprland
  environment.etc."xdg/wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=Hyprland Wayland Compositor
    Exec=${pkgs.hyprland}/bin/hyprland
    Type=Application
  '';

  # Add Hyprland to the display manager sessions
  services.xserver.displayManager.sessionPackages = with pkgs; [
    hyprland
  ];
}

