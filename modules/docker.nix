{ config, pkgs, ... }:


{
   environment.systemPackages = [
    pkgs.docker
  ];

  users.users.jake.extraGroups = ["docker"];
}
