# We add 'pristinePkgs' to the function signature to receive it from the flake.
{ config, pkgs, pristinePkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/amd.nix
    ./modules/flatpak.nix
    ./modules/nix.nix
    ./modules/nix-ld.nix
    ./modules/bluray.nix
    ./modules/boot.nix
    ./modules/network.nix
    ./modules/locale.nix
    ./modules/desktop.nix
    ./modules/audio.nix
    ./modules/users.nix
    ./modules/unfree.nix
    ./modules/global-packages.nix
    ./modules/virtualization.nix
    ./modules/gaming.nix # The module that likely overrides pkgs.xorg
    ./modules/docker.nix
  ];

  # ==> THIS IS THE FIX <==
  # We use the 'pristinePkgs' set, which is immune to the gaming module's
  # overrides, to define the fonts.
  fonts.packages = with pristinePkgs; [
    xorg.xfonts100dpi
    xorg.xfonts75dpi
    xorg.fontmiscmisc
    xorg.fontadobe100dpi
  ];

  system.stateVersion = "24.11";

  # Global settings can be added here if necessary
}
