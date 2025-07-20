{ config, pkgs, inputs, ... }:

{
  boot = {
    # This block now correctly provides the script text as a string 
    initrd.postDeviceCommands = ''
      # Wait for 5 seconds to give the theme time to load
      sleep 5
    '';

    plymouth = {
      enable = true;
      theme = "abstract-ring-alt";
      themePackages = [
        (pkgs.stdenv.mkDerivation {
          name = "my-custom-plymouth-theme";
          src = inputs.self + "/plymouth-themes/abstract-ring-alt";
          installPhase = ''
            mkdir -p $out/share/plymouth/themes/abstract-ring-alt
            cp -R ./* $out/share/plymouth/themes/abstract-ring-alt/
          '';
        })
      ];
    };

    # Restore the boot entry limit
    loader.systemd-boot.configurationLimit = 5;

    # Other boot options
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
