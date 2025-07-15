# modules/hyprland.nix
{ config, pkgs, lib, ... }:

{
  services.xserver = {
    enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # Essential for X11 applications on Wayland
  };

  # For AMD, you typically don't need explicit 'modesetting.enable' like NVIDIA.
  # 'hardware.graphics.enable' is the new recommended option for enabling general graphics.
  hardware.graphics.enable = true; # Renamed from hardware.opengl.enable

  # Environment variables for Wayland applications (optional but recommended)
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1"; # For Chromium-based apps to use Wayland natively
    # WLR_NO_HARDWARE_CURSORS = "1"; # Uncomment if you have cursor issues
  };

  environment.systemPackages = [
    # Bar at top
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    }))
    # Screen capping tools (FIXED: Use kdePackages.xwaylandvideobridge)
    pkgs.kdePackages.xwaylandvideobridge
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard-rs
    # Notifications daemon
    pkgs.dunst
    # Notification library (dunst uses this)
    pkgs.libnotify
    # Networkmanager applet for Waybar (if you use NetworkManager)
    pkgs.networkmanagerapplet
    # You mentioned eww, if you use it for widgets/bars
    pkgs.eww
    # Wallpaper utility
    pkgs.swww
    # App launcher (assuming this rofi works for Wayland, or use pkgs.rofi-wayland if available/preferred)
    (pkgs.rofi.override { })
    # Icons
    pkgs.font-awesome
  ];

  xdg.portal.enable = true;
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk]; # Uncomment if you need a specific portal backend

  # Create a session file for Hyprland so it appears in Display Managers
  environment.etc."xdg/wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=A dynamic tiling Wayland compositor
    Exec=Hyprland
    Type=Application
    Keywords=wayland;hyprland;compositor;
  '';

  # Renamed from services.xserver.displayManager.sessionPackages
  services.displayManager.sessionPackages = with pkgs; [
    hyprland
  ];

  # Renamed from fonts.fonts
  fonts.packages = with pkgs; [
    pkgs.nerdfonts # Important for many modern UIs and icons
    pkgs.font-awesome
  ];
}
