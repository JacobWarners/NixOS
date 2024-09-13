{ config, pkgs, ... }:

{
  imports =
    [ ./hardware-configuration.nix
      ./modules/users.nix
      ./modules/desktop.nix
      ./modules/network.nix
      ./modules/nvidia.nix
      ./modules/egpu.nix
      ./modules/gaming.nix
      ./modules/docker.nix
    ];

  # Global system settings can be added here if needed
}

