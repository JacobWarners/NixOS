{ config, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.luks.devices."luks-39aceaaa-0108-4cd2-b028-5d3caff491fc" = {
      device = "/dev/disk/by-uuid/39aceaaa-0108-4cd2-b028-5d3caff491fc";
    };
  };
}

