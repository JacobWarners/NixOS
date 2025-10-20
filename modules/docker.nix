{ config, pkgs, ... }:


{
  virtualisation.docker.enable = true;
  virtualisation.docker.enableOnBoot = false;
  environment.systemPackages = [
    pkgs.docker
    pkgs.docker-compose
  ];

}
