{ config, pkgs, ... }:


{
   virtualisation.docker.enable = true;
   environment.systemPackages = [
    pkgs.docker
    pkgs.docker-compose
  ];

  users.users.jake.extraGroups = ["docker"];
}
