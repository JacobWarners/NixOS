{ config, pkgs, ... }:


{
  virtualisation.docker.enable
   environment.systemPackages = [
    pkgs.docker
  ];

  users.users.jake.extraGroups = ["docker"];
}
