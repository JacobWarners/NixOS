# modules/hyprland.nix
{ config, pkgs, lib, ... }: # Module header, essential for all NixOS modules

{
  # services.xserver.enable is typically managed by a display manager or can be enabled here.
  # If you disable your display manager, you might need 'services.xserver.enable = true;'
  # to ensure XWayland compatibility for X11 applications.
  services.xserver = {
    enable = true;
  };

  programs.hyprland = {
    enable = true;
    xwayland.enable = true; # Essential for X11 applications on Wayland
  };

  # Hardware configuration for graphics.
  # For AMD GPUs, 'hardware.graphics.enable = true;' is usually sufficient.
  # The old 'hardware.opengl.enable' is renamed.
  hardware.graphics.enable = true;

  # Environment variables for Wayland applications.
  # NIXOS_OZONE_WL for Chromium-based apps on Wayland.
  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
    # Uncomment the line below if you experience cursor issues.
    # WLR_NO_HARDWARE_CURSORS = "1";
  };

  # System-wide packages typically used in a Hyprland environment.
  environment.systemPackages = [
    # Waybar - a highly customizable Wayland bar.
    (pkgs.waybar.overrideAttrs (oldAttrs: {
      mesonFlags = oldAttrs.mesonFlags ++ ["-Dexperimental=true"]; # Enables experimental Waybar features
    }))
    # Screen capturing tools for Wayland.
    # xwaylandvideobridge - FIXED: now explicitly `kdePackages.xwaylandvideobridge`
    pkgs.kdePackages.xwaylandvideobridge
    pkgs.grim # Command-line screenshot tool
    pkgs.slurp # Select a region on screen
    pkgs.wl-clipboard-rs # Wayland clipboard utilities
    # Notification daemon.
    pkgs.dunst
    pkgs.libnotify # Library used by dunst for notifications
    # Network management applet, often used in Waybar.
    pkgs.networkmanagerapplet
    # Eww - another option for custom widgets/bars.
    pkgs.eww
    # SwWw - Wayland wallpaper setter.
    pkgs.swww
    # Rofi - application launcher (ensure it's Wayland-compatible).
    (pkgs.rofi.override { }) # Override empty, assuming base pkgs.rofi is good or will be customized
    # Font Awesome for icons.
    pkgs.font-awesome
  ];

  # XDG portal for desktop integration (e.g., file pickers, screenshots).
  xdg.portal.enable = true;
  # Uncomment the line below if you need a specific portal backend (e.g., for GTK apps).
  # xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk];

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
  # Renamed from services.xserver.displayManager.sessionPackages.
  services.displayManager.sessionPackages = with pkgs; [
    hyprland
  ];

  # Font packages for the system.
  # Renamed from fonts.fonts.
  # Now explicitly lists font-awesome and all available Nerd Fonts.
  fonts.packages = with pkgs; [
    pkgs.font-awesome
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts); # Includes all Nerd Fonts
}
