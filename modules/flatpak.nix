{ config, pkgs, ... }:

##This is only for prusa cause too hard
## And now zoom

{
#  xdg.mime.enable = true;
  xdg.mime.defaultApplications = {
    "x-scheme-handler/zoommtg" = "us.zoom.Zoom.desktop";
  };
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}

