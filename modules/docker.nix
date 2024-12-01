{ config, pkgs, ... }:


{
  virtualization.docker.enable = true;
   environment.systemPackages = [
    pkgs.docker
  ];

  users.users.jake.extraGroups = ["docker"];
}
