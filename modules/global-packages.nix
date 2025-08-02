# This file is now simple. It just defines packages and other programs.
# The font definition has been moved to configuration.nix to solve the override issue.
{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    pciutils
    vim
    xclip
    vim-full
    kitty
    wget
    mpv
    git
    nautilus
    btop
    mpg123
    mullvad
    ffmpeg
    nfs-utils
    obs-studio
    discord
    firefox
    librewolf
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
    monero-gui
    killall
    ripgrep-all
    unzip
    gnome-tweaks
    lshw
    ethtool
    jq
    audacity
    pavucontrol
    p7zip
    displaylink
    tree
    pstree
    file
 #   drawio
    terraform
    awscli2
    ssm-session-manager-plugin
 #   google-cloud-sdk
    nixpkgs-fmt
    vdhcoapp
 #   google-cloud-sdk-gce
    envsubst
    kubectl
    kubernetes
    cri-tools
    runc
    containerd
    openssl
    k9s
    kubernetes-helm
#    python3
    esptool
    adafruit-ampy
    minicom
    picocom
    platformio
    arduino
    arduino-ide
    arduino-cli
  ];


  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = with pkgs; [ vdhcoapp ];
  };
}
