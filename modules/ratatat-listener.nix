# /etc/nixos/configuration.nix
{ config, pkgs, ... }:
{
  # ... other configurations
  services.ratatat-listener.enable = true;
}
