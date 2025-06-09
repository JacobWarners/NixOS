{ config, pkgs, ... }:

##This is only for prusa cause too hard

{
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}

