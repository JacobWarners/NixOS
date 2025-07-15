{ config, pkgs, lib, ... }:

{
  services.xserver = {
    enable = true;
  };
    programs.hyprland = {
    enable = true;
    xwayland.enable = true; # Essential for X11 applications on Wayland
  };
  environment.systemPackages = [
    # Bar at top
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"];
    }))
    # Screen capping tools
    pkgs.xwaylandvideobridge
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard-rs
    # Notifications daemon
    pkgs.dunst
    # Notification library (dunst uses this)
    pkgs.libnotify
    # Networkmanager applet for Waybar
    pkgs.networkmanagerapplet
    # You mentioned eww, if you use it for widgets/bars
    pkgs.eww
    # Wallpaper utility
    pkgs.swww
    # App launcher
    (pkgs.rofi.override {
      # If using rofi for Wayland, ensure it's compiled with Wayland support.
      # You might need to check rofi-wayland specifically if this doesn't work.
      # Or, if your `rofi-wayland` was a separate package, use that.
      # For now, assuming pkgs.rofi works with wayland or you explicitly had rofi-wayland.
      # pkgs.rofi-wayland is usually the better choice.
    })
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

  services.xserver.displayManager.sessionPackages = with pkgs; [
    hyprland
  ];

  fonts.fonts = with pkgs; [
    pkgs.nerdfonts # Important for many modern UIs and icons
    pkgs.font-awesome
  ];
}
