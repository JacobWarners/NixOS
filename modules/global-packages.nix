# This file is now simple. It just defines packages and other programs.
# The font definition has been moved to configuration.nix to solve the override issue.
{ config, pkgs, ... }:

let
  patchedLibreWolf = pkgs.librewolf.overrideAttrs (oldAttrs: {
    postInstall = (oldAttrs.postInstall or "") + ''
      # Point to the location of the browser files
      cd $out/lib/librewolf/browser
      
      # Unpack the UI definitions
      if [ -f omni.ja ]; then
        mkdir -p /tmp/lw-patch
        cp omni.ja /tmp/lw-patch/
        pushd /tmp/lw-patch
        
        ${pkgs.unzip}/bin/unzip omni.ja chrome/browser/content/browser/browser.xhtml
        
        # The Patch: Change reserved="true" to reserved="false" for Ctrl+W
        sed -i 's/id="key_close"\(.*\)reserved="true"/id="key_close"\1reserved="false"/' chrome/browser/content/browser/browser.xhtml
        
        # Repack
        ${pkgs.zip}/bin/zip -0 omni.ja chrome/browser/content/browser/browser.xhtml
        popd
        cp /tmp/lw-patch/omni.ja omni.ja
        rm -rf /tmp/lw-patch
      fi
    '';
  });
in

{
  environment.systemPackages = with pkgs; [
    pciutils
    vim
    zoom-us
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
    patchedLibreWolf
    #librewolf
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
    cargo
##### WORK ##########
    notion-app-enhanced
];

}
