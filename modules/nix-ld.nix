{ config, pkgs, nix-ld, ... }:

let
  # Import 24.05 without a hash (allowed because you use --impure)
  pkgs2405 = import (builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/nixos-24.05.tar.gz";
  }) { system = pkgs.system; };
in
{
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    pkgs2405.libxml2
    
    libxslt
    glibc
    # libxml2  <-- Removed the system version to avoid conflicts
    libsForQt5.qtwayland
    nss
    nspr
    kdePackages.qtwayland
    openssl
    xorg.libXfixes
    xorg.libXrandr
    xorg.libXtst
    xorg.libxcb
    expat
    alsa-lib
    xorg.libxkbfile
    vulkan-loader
    xorg.xcbutil
    xorg.xcbutilcursor
    xorg.xcbutilrenderutil
    xorg.xcbutilkeysyms
    xorg.xcbutilimage
    xorg.xcbutilwm
    zlib
    brotli.lib
    stdenv.cc.cc.lib
    fontconfig
    freetype
    xorg.libX11
    xorg.libXext
    libxkbcommon
    libglvnd
    dbus
    # nss  <-- Removed duplicate (you had it listed twice)
    # nspr <-- Removed duplicate (you had it listed twice)
    xorg.libXcomposite
    xorg.libXdamage
    libevent
    libdrm
  ];
}
