{ config, pkgs, ... }:

let
  # This uses a different, simpler builder as a test
  myCustomPlymouthTheme = pkgs.runCommand "abstract-ring-alt-plymouth-theme" { } ''
    # Here, we hard-code the theme name instead of using a variable
    mkdir -p $out/share/plymouth/themes/abstract-ring-alt
    cp -r ${../plymouth-themes/abstract_ring_alt}/* $out/share/plymouth/themes/abstract-ring-alt/
  '';
in
{
  boot.plymouth = {
    enable = true;
    theme = "abstract-ring-alt";
    themePackages = [ myCustomPlymouthTheme ];
  };

  # The rest of your boot config...
  consoleLogLevel = 0;
  initrd.verbose = false;
  kernelParams = [
    "quiet"
    "splash"
    "udev.log_priority=3"
    "rd.systemd.show_status=auto"
    "amdgpu.modeset=1"
  ];

  kernelPackages = pkgs.linuxPackages_latest;
  supportedFilesystems = [ "nfs" ];
  loader = {
    systemd-boot.enable = true;
    efi.canTouchEfiVariables = true;
    systemd-boot.configurationLimit = 5;
  };
  initrd = {
    systemd.enable = true;
    kernelModules = [ "amdgpu" ];
    luks.devices."luks-6cb1713b-252a-435f-8c5c-d4b404e9db96" = {
      device = "/dev/disk/by-uuid/6cb1713b-252a-435f-8c5c-d4b404e9db96";
    };
  };
}
