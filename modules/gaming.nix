{ config, pkgs, ... }:

{
  # Enable Steam
  hardware.graphics.enable32Bit = true;
  services.pulseaudio.support32Bit = true;

  # Install FFXIV launcher (assuming it's available in Nixpkgs)
  environment.systemPackages = with pkgs; [
    steam
    mesa
    vulkan-loader
    libglvnd
    libva
    xivlauncher
    lutris
    wine
    winetricks
  ];

}

