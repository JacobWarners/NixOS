# /home/jake/nixos-config/modules/boot.nix
{ config, pkgs, ... }:

{
  boot = {
    plymouth = {
      enable = true;
      theme = "abstract-ring-alt";
      themePackages = [
        (pkgs.stdenv.mkDerivation {
          # We set the package name directly, without using pname
          name = "abstract-ring-alt-theme";

          src = ../plymouth-themes/abstract-ring-alt;

          installPhase = ''
            # We hard-code the theme name in the destination path
            local THEME_DIR="$out/share/plymouth/themes/abstract-ring-alt"
            mkdir -p "$THEME_DIR"
            cp -R ./* "$THEME_DIR"
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
