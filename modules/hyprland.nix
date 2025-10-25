# modules/hyprland.nix
{ config, pkgs, lib, ... }:

{
  # 1. Hyprland Core Configuration
  # Enables the Hyprland window manager and XWayland for compatibility with X11 apps.
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
    
    # 1a. Hyprland Extra Configuration (THE NEW FIX IS HERE)
    # This adds custom rules to the hyprland.conf file. We are telling Hyprland
    # to force any pop-up or dialog window from Zoom to "float" on top of
    # other windows, rather than trying to tile it. This prevents the SSO
    # window from being hidden or becoming unresponsive.
    extraConfig = ''
      # Make Zoom's SSO and other dialog windows float
      windowrulev2 = float, class:^(zoom)$, title:^(Sign In with SSO)$
      windowrulev2 = float, class:^(zoom)$, x11_window_type:^(dialog)$
    '';
  };

  # Ensures necessary graphics drivers are enabled.
  hardware.graphics.enable = true;

  # Set environment variables for Wayland sessions.
  # NIXOS_OZONE_WL=1 forces Electron/Chromium apps to use Wayland natively.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # 2. Flatpak & XDG Portal Configuration
  # This configures the portals needed for Flatpak apps to function correctly.
  services.flatpak.enable = true;
  xdg.portal = {
    enable = true;
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
  environment.systemPackages = with pkgs; [
    waybar
    grim
    slurp
    wl-clipboard-rs
    dunst
    libnotify
    rofi
    swww
    networkmanagerapplet
    eww
    kdePackages.xwaylandvideobridge
    font-awesome
    # Add Flatseal here for easier debugging of Flatpak permissions
    flatseal
  ];

  # 5. Display Manager Integration
  services.displayManager.sessionPackages = with pkgs; [
    hyprland
  ];
  
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
