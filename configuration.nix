{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    #    ./modules/specialisation.nix
    #    ./modules/hotplugegpu.nix
    ./modules/hyprland.nix
    ./modules/amd.nix
    ./modules/transcriber.nix
    ./modules/flatpak.nix
    ./modules/nix.nix
    ./modules/nix-ld.nix
    ./modules/bluray.nix
    ./modules/boot.nix
    ./modules/network.nix
    ./modules/locale.nix
    ./modules/desktop.nix
    #    ./modules/nvidia-egpu.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/unfree.nix
    ./modules/global-packages.nix
    ./modules/virtualization.nix
    ./modules/gaming.nix
    ./modules/docker.nix
    # Add any other modules you have
  ];

  system.stateVersion = "24.11";

  # Global settings can be added here if necessary

}

