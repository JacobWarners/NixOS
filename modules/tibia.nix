{ config, pkgs, nix-ld, ... }:

{
  imports = [
    nix-ld.nixosModules.nix-ld
  ];

  programs.nix-ld.dev.enable = true;
}

