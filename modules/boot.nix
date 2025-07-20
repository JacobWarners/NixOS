# This line is important - we add 'inputs' to access the flake's inputs
{ config, pkgs, inputs, ... }:

{
  boot = {
    plymouth = {
      enable = true;
      theme = "abstract-ring-alt";
      themePackages = [
        (pkgs.stdenv.mkDerivation {
          pname = "abstract-ring-alt";
          version = "1.0.0";

          # This is the key change. 
          # It uses the absolute path from the flake's root directory.
          src = inputs.self + "/plymouth-themes/abstract-ring-alt";

          installPhase = ''
            mkdir -p $out/share/plymouth/themes/${pname}
            cp -R ./* $out/share/plymouth/themes/${pname}/
          '';
        })
      ];
    };

    # Other Boot Options
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
