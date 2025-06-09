{ config, pkgs, ... }:

##This is only for prusa cause too hard

{
  xdg.mime.defaultApplication = {
    "x-scheme-handler/zoommtg" = "us.zoom.Zoom.desktop";
  };
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}

