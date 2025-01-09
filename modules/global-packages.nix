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
#    prusa-slicer
    p7zip
    tree
    file
    drawio

    #Work ish stuff
    terraform
    awscli
    google-cloud-sdk
    # Add any other global packages here
    nixpkgs-fmt
    #Kubestuff
    google-cloud-sdk-gce
    envsubst
    kubectl
    kubernetes
    cri-tools
    runc
    containerd
    etcd
    openssl
    k9s
    kubernetes-helm



  ];
}

