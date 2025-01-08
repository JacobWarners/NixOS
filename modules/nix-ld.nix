{ config, pkgs, nix-ld, ... }:

{
  programs.nix-ld.enable = true;

  programs.nix-ld.libraries = with pkgs; [
    libxslt
    glibc
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
    nss
    nspr
    xorg.libXcomposite
    xorg.libXdamage 
    libevent
    libdrm
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
