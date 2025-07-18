{ config, pkgs, ... }:


{
  virtualisation.docker.enable = false;
  environment.systemPackages = [
    pkgs.docker
    pkgs.docker-compose
  ];

  users.users.jake.extraGroups = [ "docker" ];
}
