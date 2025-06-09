{ config, pkgs, ... }:

##This is only for prusa cause too hard

{
    xdg.data.paths = [
      "/var/lib/flatpak/exports/share"
    ];
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}

