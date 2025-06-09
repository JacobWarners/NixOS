# We receive pristinePkgs from the flake.nix specialArgs
{ config, pkgs, pristinePkgs, ... }:

# We use a 'let' binding to extract the *actual* package set from the
# raw 'pristinePkgs' flake input. This is the final, crucial step.
let
  finalPristinePkgs = pristinePkgs.legacyPackages.${config.nixpkgs.system};
in

{
  # This section remains unchanged and uses the standard 'pkgs'.
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
    terraform
    awscli2
    ssm-session-manager-plugin
    google-cloud-sdk
    zoom-us
    nixpkgs-fmt
    vdhcoapp
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

  # Here, we use our 'finalPristinePkgs' variable which is now a proper
  # package set that is guaranteed to contain the .xorg attribute.
  fonts.packages = [
    finalPristinePkgs.xorg.xfonts100dpi
    finalPristinePkgs.xorg.xfonts75dpi
    finalPristinePkgs.xorg.fontmiscmisc
    finalPristinePkgs.xorg.fontadobe100dpi
  ];

  # This section remains unchanged.
  programs.firefox = {
    enable = true;
    nativeMessagingHosts.packages = with pkgs; [ vdhcoapp ];
  };
}
