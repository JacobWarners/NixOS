# /etc/nixos/configuration.nix
{ config, pkgs, lib, ... }:

{
  environment.systemPackages = with pkgs; [
    keyd
  ];

  # Override the keyd service to use the config from your home directory
  systemd.services.keyd = {
    enable = true;
    serviceConfig = {
      ExecStart = "/run/current-system/sw/bin/keyd -c /home/jake/.config/keyd";  # Adjust the path as needed
    };
    wantedBy = [ "multi-user.target" ];
  };
}

