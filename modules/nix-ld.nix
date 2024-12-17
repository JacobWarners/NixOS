{ config, pkgs, nix-ld, ... }: # Add `nix-ld` here

{
  imports = [
    nix-ld.nixosModules.nix-ld # Reference nix-ld here
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

