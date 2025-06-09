{ config, pkgs, ... }:

# We define 'nixpkgs' here to capture the original, unmodified package set.
# This prevents errors if another module overrides 'pkgs.xorg'.
let
  nixpkgs = pkgs;
in

{
  # This is the list of packages to install globally.
  environment.systemPackages = with pkgs; [
    pciutils
    vim
    xclip
    kitty
    wget
    git
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
    mesa # Note: I removed .drivers as per the deprecation warning
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
    file
    drawio

    # Work ish stuff
    terraform
    awscli2
    ssm-session-manager-plugin
    google-cloud-sdk
    zoom-us # Changed from 'zoom' to 'zoom-us', the standard name in Nixpkgs

    # Add any other global packages here
    nixpkgs-fmt
    vdhcoapp

    # Kubestuff
    google-cloud-sdk-gce
    envsubst
    kubectl
    kubernetes
    cri-tools
    runc
    containerd
    openssl
    k9s
    kubernetes-helm

    # esp32 stuff
    python3
    esptool
    adafruit-ampy
    minicom
    picocom
    platformio
    arduino
    arduino-ide
    arduino-cli
  ];

  # This is the correct, top-level location for font configuration.
  # We use our 'nixpkgs' variable here to ensure we get the full, original xorg package set.
  fonts.packages = [
    nixpkgs.xorg.xfonts100dpi
    nixpkgs.xorg.xfonts75dpi
    nixpkgs.xorg.fontmiscmisc
    nixpkgs.xorg.fontadobe100dpi
  ];

  # Other top-level options for this module
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = with pkgs; [ vdhcoapp ];
  };
}
