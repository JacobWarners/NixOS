{ config, pkgs, nix-ld, ... }:

let
  # Import 24.05 without a hash (allowed because you use --impure)
  pkgs2405 = import (builtins.fetchTarball {
    url = "https://github.com/nixos/nixpkgs/archive/nixos-24.05.tar.gz";
  }) { system = pkgs.stdenv.hostPlatform.system; };
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
    libxfixes
    libxrandr
    libxtst
    libxcb
    expat
    alsa-lib
    libxkbfile
    vulkan-loader
    libxcb-util
    libxcb-cursor
    libxcb-render-util
    libxcb-keysyms
    libxcb-image
    libxcb-wm
    zlib
    brotli.lib
    stdenv.cc.cc.lib
    fontconfig
    freetype
    libx11
    libxext
    libxkbcommon
    libglvnd
    dbus
    # nss  <-- Removed duplicate (you had it listed twice)
    # nspr <-- Removed duplicate (you had it listed twice)
    libxcomposite
    libxdamage
    libevent
    libdrm
    # Tibia launcher self-updated to Qt 6.10.3 on 2026-09-15; its xcb plugin
    # now links libSM/libICE, and the wayland plugin has always needed
    # libwayland-client/cursor/egl. Without these both QPA plugins fail -> abort.
    libsm
    libice
    wayland
  ];
}
