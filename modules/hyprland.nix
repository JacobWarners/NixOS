{ config, pkgs, lib, ... }:

{
  programs.hyprland = {
    enable = true;
    xwayland.enable = true;
  };

  hardware.graphics.enable = true;

  environment.sessionVariables = {
    NIXOS_OZONE_WL = "1";
  };

  # === THIS IS THE FINAL FIX ===
  # All other xdg.portal blocks must be removed. This single block
  # correctly configures the portals for Hyprland and GTK apps (like Steam).
  services.flatpak.enable = true;
  xdg-desktopEntries."firefox-as-librewolf" = {
  	name = "Firefox";
	genericName = "Web Browser";
	comment = "Browse the web with librewolf"
	exec = "librewolf %U";
	icon = "librewolf";
	terminal = false;
	type = "Application";
	categories = ["Network" "WebBrowser"];
	keywords = [ "Internet" "WWW" "Browser" "firefox" "Firefox" "Web" ];


  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
  };
    xdg.mime = {
    enable = true;
    defaultApplications = {
    "x-scheme-handler/zoommtg" = "us.zoom.Zoom.desktop";
    "x-scheme-handler/http" = "chromium-browser.desktop";
    "x-scheme-handler/https" = "chromium-browser.desktop";
  };
  };

  # System-wide packages typically used in a Hyprland environment.
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

  # Font packages for the system.
  fonts.packages = with pkgs; [
    pkgs.font-awesome
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
