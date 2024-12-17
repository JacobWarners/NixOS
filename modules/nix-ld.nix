{ config, pkgs, ... }:

{
  imports = [
    # Correctly reference nix-ld's module
    inputs.nix-ld.nixosModules.nix-ld
  ];

  programs.nix-ld.dev.enable = true;

  programs.nix-ld.dev.libraries = with pkgs; [
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

