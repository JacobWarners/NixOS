# We add 'pristinePkgs' to the function signature to receive it from 'specialArgs' in your flake.nix
{ config, pkgs, pristinePkgs, ... }:

{
  # This list of packages is fine.
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

  # We use the 'pristinePkgs' we received from the flake.nix specialArgs.
  # This is the pure, Flakes-native way to solve the override problem.
  fonts.packages = [
    pristinePkgs.xorg.xfonts100dpi
    pristinePkgs.xorg.xfonts75dpi
    pristinePkgs.xorg.fontmiscmisc
    pristinePkgs.xorg.fontadobe100dpi
  ];

  # Other top-level options for this module
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = with pkgs; [ vdhcoapp ];
  };
}
