{ config, pkgs, inputs, ... }:

{
  boot = {
    # This block ensures your AMD graphics driver loads early
    initrd.kernelModules = [ "amdgpu" ];

    # Add this line to force early loading for Plymouth
    initrd.availableKernelModules = [ "amdgpu" ];

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
      "rd.systemd.show_status=auto"
    ];

    kernelPackages = pkgs.linuxPackages_latest;
    loader.systemd-boot.enable = true;
    loader.efi.canTouchEfiVariables = true;
  };
}
