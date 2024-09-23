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
    wlogout
    signal-desktop
    home-manager
    brightnessctl
    wireguard-tools
    bat
    htop
    kanshi
    glxinfo
    mesa
    killall
    ripgrep-all
    # Add any other global packages here
  ];
}

