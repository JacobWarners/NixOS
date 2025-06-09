{ config, pkgs, ... }:

##This is only for prusa cause too hard

{

  environment.sessionVariables = {
        XDG_DATA_DIRS = "$XDG_DATA_DIRS:/var/lib/flatpak/exports/share";
          };
  services.flatpak.enable = true;
  xdg.portal.enable = true;
  xdg.portal.extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
}

