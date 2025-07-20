{ config, pkgs, ... }:

let
  # A simplified test derivation
  myCustomPlymouthTheme = pkgs.stdenv.mkDerivation {
    pname = "abstract-ring-alt";
    version = "1.0";

    # We remove the 'src' and just create an empty directory and a test file.
    installPhase = ''
      mkdir -p $out/share/plymouth/themes/${pname}
      touch $out/share/plymouth/themes/${pname}/test-file
    '';
  };
in
{
  boot = {
    consoleLogLevel = 0;
    initrd.verbose = false;
    kernelParams = [
      "quiet"
      "splash"
      "udev.log_priority=3"
      "rd.systemd.show_status=auto"
      "amdgpu.modeset=1"
    ];

    plymouth = {
      enable = true;
      theme = "abstract-ring-alt";
      themePackages = [ myCustomPlymouthTheme ];
    };

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
  };
}
