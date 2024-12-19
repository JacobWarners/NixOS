{ config, pkgs, nix-ld, ... }:

{
  programs.nix-ld.enable = true;

  # List of required libraries, with updates to remove libstdcxx5.
  programs.nix-ld.libraries = with pkgs; [
    # Core runtime libraries
    glibc

    # Compression libraries
    zlib
    brotli.lib  # For libbrotlidec.so.1

    # C++ standard library
    stdenv.cc.cc.lib  # Provides libstdc++.so.6

    # Font and rendering libraries
    fontconfig
    freetype

    # X11 and input libraries
    xorg.libX11
    libxkbcommon

    # Graphics libraries
    libglvnd  # Provides libEGL.so.1, libGLX.so.0, libOpenGL.so.0

    # DBus for inter-process communication
    dbus
  qt6.qtbase
  qt6.qtwayland
  nss
  ];
}
#{
#  imports = [
#    nix-ld.nixosModules.nix-ld
#  programs.nix-ld.enable = true;
#  ];
##programs.nix-ld.libraries = with pkgs; [
#    glibc
#    zlib
##    libstdcxx5
#    openssl
#    nss
#    nspr
##    libX11
##    libxcb
#    xcbutil
#    xcbutilcursor
#    xcbutilrenderutil
#    libxkbcommon
#    fontconfig
#    freetype
#    dbus
#    libglvnd
#    brotli.lib
#    wayland
#    gtk2
#    stdenv.cc.cc.lib
#    brotli
#    xorg.libX11
#    libglvnd
#  ];
#}
#
