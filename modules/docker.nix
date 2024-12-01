{ config, pkgs, ... }:


{
  services.docker.enable = true;
  users.users.jake.extraGroups = ["docker"];
}
