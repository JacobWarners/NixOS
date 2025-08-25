{ config, pkgs, lib, ... }:

{
  # === Hyprland Program Configuration ===
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  # === Graphics and Environment Variables ===
  hardware.graphics.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # === Flatpak Configuration ===
  services.flatpak.enable = true;

  # === XDG Portal Configuration (The Final Fix) ===
  # This single block correctly configures the portals for Hyprland.
  # It explicitly tells the system to use the hyprland backend for key functions.
  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];

    # This configuration explicitly forces the hyprland portal backend.
    # It addresses the D-Bus errors by ensuring the correct backend is used.
    config = {
      common = {
        "org.freedesktop.portal.Filer" = "gtk";
        "org.freedesktop.portal.FileChooser" = "gtk";
        "org.freedesktop.portal.Request" = "hyprland";
        "org.freedesktop.portal.Screenshot" = "hyprland";
      };
    };
  };

  # === Default Application Handlers ===
  # This block is for setting default applications for specific protocols.
  # It must be outside the xdg.portal block.
  xdg.mime.defaultApplications = {
    "x-scheme-handler/zoommtg" = "us.zoom.Zoom.desktop";
    "x-scheme-handler/http" = "firefox.desktop";
    "x-scheme-handler/https" = "firefox.desktop";
  };

  # === System-wide Packages ===
  # Add packages available to all users.
  environment.systemPackages = [
    pkgs.waybar
    pkgs.kdePackages.xwaylandvideobridge
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard-rs
    pkgs.dunst
    pkgs.libnotify
    pkgs.networkmanagerapplet
    pkgs.eww
    pkgs.swww
    pkgs.rofi
    pkgs.font-awesome
  ];

  # === Display Manager and Session Configuration ===
  # Define the .desktop file for Hyprland so display managers can find it.
  environment.etc."xdg/wayland-sessions/hyprland.desktop".text = ''
    [Desktop Entry]
    Name=Hyprland
    Comment=A dynamic tiling Wayland compositor
    Exec=Hyprland
    Type=Application
    Keywords=wayland;hyprland;compositor;
  '';

  # Ensure Hyprland is available as a session in display managers.
  services.displayManager.sessionPackages = with pkgs; [
    hyprland
  ];

  # === Font Packages ===
  # Add font packages to the system.
  fonts.packages = with pkgs; [
    pkgs.font-awesome
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
