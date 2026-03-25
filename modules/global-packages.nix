# This file is now simple. It just defines packages and other programs.
# The font definition has been moved to configuration.nix to solve the override issue.
{ config, pkgs, ... }:
let
  # Define the wrapped version here
  rustdesk-wayland = pkgs.symlinkJoin {
    name = "rustdesk";
    paths = [ pkgs.rustdesk-flutter ];
    buildInputs = [ pkgs.makeWrapper ];
    postBuild = ''
      wrapProgram $out/bin/rustdesk \
        --set XDG_SESSION_TYPE wayland \
        --set QT_QPA_PLATFORM wayland
    '';
  };

  # Force Zoom to XWayland — fixes broken key input under native Wayland
  zoom-xcb = pkgs.writeShellScriptBin "zoom" ''
    export QT_QPA_PLATFORM=xcb
    exec ${pkgs.zoom-us}/bin/zoom "$@"
  '';
in
{
  environment.systemPackages = with pkgs; [
    pciutils
    vim
    zoom-xcb
    yq
    sops
    tigervnc
    freerdp
    xclip
    vim-full
    kitty
    wget
    mpv
    appimage-run
    git
    nautilus
    btop
    mpg123
    mullvad
    mullvad-vpn
    ffmpeg
    nfs-utils
    rpcbind
    obs-studio
    discord
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
    mesa-demos
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
   # displaylink
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

   # esptool
    adafruit-ampy
    minicom
    picocom
    platformio
    arduino
    arduino-ide
    arduino-cli
    rustc
    rustup
    rustdesk-wayland
    cargo
##### WORK ##########
    notion-app-enhanced
];

}
