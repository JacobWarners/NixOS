# modules/hyprland.nix
{ config, pkgs, lib, ... }:

{
  # 1. Hyprland Core Configuration
  # Enables the Hyprland window manager and XWayland for compatibility with X11 apps.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # Ensures necessary graphics drivers are enabled.
  hardware.graphics.enable = true;

  # Set environment variables for Wayland sessions.
  # NIXOS_OZONE_WL=1 forces Electron/Chromium apps to use Wayland natively.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # 2. Flatpak & XDG Portal Configuration (THE FIX IS HERE)
  # This single, consolidated block correctly configures the portals needed
  # for Flatpak apps (like Zoom) to function correctly under Hyprland.
  # It solves the issue with unclickable buttons in apps like Zoom SSO.
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
    # We must include both the hyprland and gtk portals.
    # - hyprland: For screen sharing, window management requests.
    # - gtk: For file pickers and other dialogs in GTK-based apps.
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };

  # 3. Default Applications & MIME Types
  # This tells the system which application to use for different links/protocols.
  xdg.mime.defaultApplications = {
    "x-scheme-handler/zoommtg" = "us.zoom.Zoom.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
  };

  # 4. Essential System Packages for a Hyprland Environment
  # These are the tools and utilities that make the desktop experience complete.
  environment.systemPackages = with pkgs; [
    # Status Bar
    waybar

    # Screen Capture & Color Picker
    grim
    slurp

    # Clipboard Manager
    wl-clipboard-rs

    # Notification Daemon
    dunst
    libnotify

    # App Launcher / Menu
    rofi

    # Wallpaper Manager
    swww
    
    # Other Utilities
    networkmanagerapplet      # System tray icon for network management
    eww                       # ElKowars Wacky Widgets, if you use it
    kdePackages.xwaylandvideobridge # For screen sharing in some apps (e.g., Discord)
    
    # Icons & Fonts
    font-awesome
  ];

  # 5. Display Manager Integration
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
    Keywords=wayland;hyprland;compositor;
  '';

  # 6. System-wide Fonts
  fonts.packages = with pkgs; [
    pkgs.font-awesome
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);

}
