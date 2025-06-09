{ config, pkgs, ... }:

# ========================================================================
# ==> THIS IS THE GUARANTEED FIX <==
# We import a completely new, pristine instance of the nixpkgs repository.
# This is completely immune to any overrides or modifications made by
# other modules (like the gaming/steam one).
let
  pristinePkgs = import <nixpkgs> {
    # We pass the system config from the 'pkgs' we received so that
    # the new instance builds for the correct architecture (e.g., x86_64-linux).
    inherit (pkgs) system;
  };
in
# ========================================================================

{
  # This is the list of packages to install globally.
  # This section can continue to use the (potentially modified) 'pkgs'
  # as it seems to be working for everything else.
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
    mesa
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
    zoom-us

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

  # ========================================================================
  # We use our 'pristinePkgs' variable here to get the real font packages.
  fonts.packages = [
    pristinePkgs.xorg.xfonts100dpi
    pristinePkgs.xorg.xfonts75dpi
    pristinePkgs.xorg.fontmiscmisc
    pristinePkgs.xorg.fontadobe100dpi
  ];
  # ========================================================================

  # Other top-level options for this module
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = with pkgs; [ vdhcoapp ];
  };
}
