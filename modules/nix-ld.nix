{ config, pkgs, nix-ld, ... }:

{
  imports = [
    nix-ld.nixosModules.nix-ld
  ];

  programs.nix-ld.libraries = with pkgs; [
    glibc
    zlib
    libstdcxx5
    openssl
    nss
    nspr
    libX11
    libxcb
    xcbutil
    xcbutilcursor
    xcbutilrenderutil
    libxkbcommon
    fontconfig
    freetype
    dbus
    libglvnd
    brotli
    wayland
    gtk2
  ];
}

