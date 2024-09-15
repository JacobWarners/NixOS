{ config, pkgs, ... }:

{
  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    initrd.luks.devices."luks-6cb1713b-252a-435f-8c5c-d4b404e9db96" = {
      device = "/dev/disk/by-uuid/6cb1713b-252a-435f-8c5c-d4b404e9db96";
 
    };
  };
}

