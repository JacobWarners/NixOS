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


  xdg.portal = {
    enable = true;
    extraPortals = with pkgs; [
      xdg-desktop-portal-hyprland
      xdg-desktop-portal-gtk
    ];
    config = {
      common = {
        default = [ "hyprland" "gtk" ];
      };
      hyprland = {
        default = [ "hyprland" "gtk" ];
        "org.freedesktop.impl.portal.ScreenCast" = "hyprland";
        "org.freedesktop.impl.portal.Screenshot" = "hyprland";
      };
    };
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
    pkgs.grim
    pkgs.slurp
    pkgs.wl-clipboard-rs
    pkgs.dunst
    pkgs.libnotify
    pkgs.networkmanagerapplet
    pkgs.eww
    pkgs.awww
    pkgs.rofi
    pkgs.font-awesome
  ];

  # NOTE: do NOT hand-write a wayland-sessions desktop file with `Exec=Hyprland`.
  # That launches the raw binary and trips Hyprland 0.55's "started without
  # start-hyprland" warning. programs.hyprland.enable already registers a proper
  # session whose Exec points at the package's start-hyprland wrapper (which sets
  # up the dbus/systemd-user env). Pick "Hyprland" in the display manager.

  # Ensure Hyprland is available as a session in display managers.
  services.displayManager.sessionPackages = with pkgs; [
    hyprland
  ];

  # Font packages for the system.
  fonts.packages = with pkgs; [
    pkgs.font-awesome
  ] ++ builtins.filter lib.attrsets.isDerivation (builtins.attrValues pkgs.nerd-fonts);
}
