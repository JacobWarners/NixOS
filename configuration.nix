{ config, pkgs, ... }:

{
  # This is the list of all modules to include in your system.
  # This must be at the top level.
  imports = [
    ./hardware-configuration.nix
    ./modules/amd.nix
    ./modules/flatpak.nix
    ./modules/nix.nix
    ./modules/nix-ld.nix
    ./modules/bluray.nix
    ./modules/boot.nix
    ./modules/network.nix
    ./modules/locale.nix
    ./modules/desktop.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/unfree.nix
    ./modules/global-packages.nix
    ./modules/virtualization.nix
    ./modules/gaming.nix
    ./modules/docker.nix
  ];

  # This enables the modern desktop portal system.
  # This is also a top-level option.
  programs.xdg.portal = {
    enable = true;
    # This backend is correct for GNOME, Sway, Wayfire, and other
    # GTK-based desktop environments.
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # This enables the system that links file types and URLs (like zoommtg://)
  # to the correct applications.
  xdg.mime.enable = true;

  # This is a required top-level option.
  system.stateVersion = "24.11";

  # Global settings can be added here if necessary
}
