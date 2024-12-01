{ config, pkgs, ... }:


{
   virtualisation.docker.enable = true;
   environment.systemPackages = [
    pkgs.docker
  ];

  users.users.jake.extraGroups = ["docker"];
}
