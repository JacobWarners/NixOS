{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pciutils
    vim
    kitty
    wget
    git
    obs-studio
    discord
    firefox
    chromium
    joplin-desktop
    signal-desktop
    cava
    # Add any other global packages here
  ];
}

