{ config, pkgs, ... }:

{
  environment.systemPackages = with pkgs; [
    vim
    kitty
    wget
    git
    hyprland
    # Add any other global packages here
  ];
}

