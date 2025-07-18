{ config, pkgs, ... }:


{
  virtualisation.docker.enable = false;
  virtualisation.docker.enableSocket = true;
  environment.systemPackages = [
    pkgs.docker
    pkgs.docker-compose
  ];

  users.users.jake.extraGroups = [ "docker" ];
}
