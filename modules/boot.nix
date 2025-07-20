{ config, pkgs, ... }:

{
  boot = {
    plymouth = {
      enable = true;
      theme = "abstract-ring-alt";
      themePackages = [
        (pkgs.stdenv.mkDerivation {
          pname = "abstract-ring-alt";
          version = "1.0.0";
          src = ../plymouth-themes/abstract-ring-alt;
          installPhase = ''
            mkdir -p $out/share/plymouth/themes/${pname}
            cp -R ./* $out/share/plymouth/themes/${pname}/
          '';
        })
      ];
    };

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
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
}
