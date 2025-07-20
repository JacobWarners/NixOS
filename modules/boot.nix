# We add 'inputs' here to get the absolute path to your configuration
{ config, pkgs, inputs, ... }:

{
  boot = {
    plymouth = {
      enable = true;
      theme = "abstract-ring-alt";
      themePackages = [
        (pkgs.stdenv.mkDerivation {
          # The package is given a simple, direct name. No 'pname' is used.
          name = "my-custom-plymouth-theme";

          # This creates a direct, absolute path to your theme files.
          src = inputs.self + "/plymouth-themes/abstract-ring-alt";

          # This script copies the files to the correct location.
          # The theme name is hard-coded to avoid any variables.
          installPhase = ''
            mkdir -p $out/share/plymouth/themes/abstract-ring-alt
            cp -R ./* $out/share/plymouth/themes/abstract-ring-alt/
          '';
        })
      ];
    };

    # Your other boot options
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
