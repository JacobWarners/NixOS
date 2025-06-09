{ config, pkgs, ... }:

{
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
    #    prusa-slicer
    p7zip
    displaylink
    tree
    file
    drawio

    #Work ish stuff
    terraform
    awscli2
    ssm-session-manager-plugin
    google-cloud-sdk
    zoom
      fonts.packages = with pkgs; [
    # ==> Add these lines <==
    xorg.xfonts100dpi
    xorg.xfonts75dpi
    xorg.fontmiscmisc
    xorg.fontadobe100dpi

    # You might already have other fonts here, leave them.
    # For example:
    # noto-fonts
    # noto-fonts-cjk
    # noto-fonts-emoji
    # font-awesome
  ];

    #   kdenlive
    # Add any other global packages here
    nixpkgs-fmt
    vdhcoapp

    #Kubestuff
    google-cloud-sdk-gce
    envsubst
    kubectl
    kubernetes
    cri-tools
    runc
    containerd
    #  etcd
    openssl
    k9s
    kubernetes-helm

    # esp32 stuff
    python3
    esptool # For flashing firmware
    adafruit-ampy # For managing MicroPython files
    minicom # Serial terminal
    picocom # Alternative serial terminal
    platformio # Development environment
    arduino
    arduino-ide
    arduino-cli


  ];

  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = with pkgs; [ vdhcoapp ];
  };
}

