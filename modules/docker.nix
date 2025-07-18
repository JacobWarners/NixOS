{ config, pkgs, ... }:


{
  virtualisation.docker.enable = false;
  virtualisation.docker.socket.enable = true;
  environment.systemPackages = [
    pkgs.docker
    pkgs.docker-compose
  ];

  users.users.jake.extraGroups = [ "docker" ];
}
