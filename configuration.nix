{ config, pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    #    ./modules/specialisation.nix
    #    ./modules/hotplugegpu.nix
    ./modules/hyprland.nix
    ./modules/amd-performance.nix
    #    ./modules/ratatat-listener.nix
    ./modules/amd.nix
    #    ./modules/transcriber.nix
    ./modules/flatpak.nix
    ./modules/nix.nix
    ./modules/nix-ld.nix
    ./modules/bluetooth.nix
    #    ./modules/bluray.nix
    ./modules/boot.nix
    ./modules/network.nix
    ./modules/locale.nix
    ./modules/desktop.nix
    #    ./modules/nvidia-egpu.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/unfree.nix
    ./modules/global-packages.nix
    #    ./modules/virtualization.nix
    ./modules/gaming.nix
    ./modules/docker.nix
    # Add any other modules you have
  ];


  system.stateVersion = "25.05";
  services.avahi = {
    enable = true;
    nssmdns4 = true;
    openFirewall = true;
  };

  programs.hyprland.enable = true;

  # Global settings can be added here if necessary

}

