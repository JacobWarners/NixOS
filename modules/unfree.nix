{ config, pkgs, ... }:

{
  nixpkgs.config.allowUnfree = true;
  nixpkgs.config.multilib = true; # Enable 32-bit libraries.
}

